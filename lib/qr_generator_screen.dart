
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String? _qrData;

  void _generateQrCode() {
    final random = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final randomNumber = List.generate(12, (index) => random[DateTime.now().microsecondsSinceEpoch % random.length]).join();
    setState(() {
      _qrData = randomNumber;
    });
  }

  Future<void> _shareQrCode() async {
    if (_qrData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero genera un código QR para poder compartirlo.')),
      );
      return;
    }

    try {
      final theme = Theme.of(context);
      final painter = QrPainter(
        data: _qrData!,
        version: QrVersions.auto,
        gapless: false,
        dataModuleStyle: QrDataModuleStyle(
          color: theme.colorScheme.onSurface,
          dataModuleShape: QrDataModuleShape.square,
        ),
        eyeStyle: QrEyeStyle(
          color: theme.colorScheme.onSurface,
          eyeShape: QrEyeShape.square,
        ),
      );

      final picData = await painter.toImageData(250.0);
      if (picData == null) {
        throw Exception('No se pudo generar la imagen del QR.');
      }
      final buffer = picData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(buffer);

      final xFile = XFile(file.path);
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [xFile],
        text: 'Aquí está tu código QR para el menú. Por favor, imprímelo y colócalo en un lugar visible de tu establecimiento para que tus clientes puedan escanearlo.',
        subject: 'Tu Código QR para Qrden',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir el QR: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Código QR'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: _qrData == null
                          ? _buildPlaceholder(textTheme)
                          : _buildQrDisplay(textTheme, _qrData!),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generar Nuevo Código'),
                    onPressed: _generateQrCode,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Enviar QR por Correo'),
                    onPressed: _qrData == null ? null : _shareQrCode,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(TextTheme textTheme) {
    return SizedBox(
      key: const ValueKey('placeholder'),
      height: 300,
      child: Center(
        child: Text(
          'Presiona "Generar" para crear un QR',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildQrDisplay(TextTheme textTheme, String data) {
    return Container(
      key: ValueKey(data),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Código de tu Negocio',
            style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            data,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
            backgroundColor: Colors.transparent,
            dataModuleStyle: QrDataModuleStyle(
              color: Theme.of(context).colorScheme.onSurface,
              dataModuleShape: QrDataModuleShape.square,
            ),
            eyeStyle: QrEyeStyle(
              color: Theme.of(context).colorScheme.onSurface,
              eyeShape: QrEyeShape.square,
            ),
          ),
        ],
      ),
    );
  }
}
