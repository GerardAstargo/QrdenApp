import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String? _qrData;

  void _generateQrCode() {
    final random = '1234567890';
    final randomNumber = List.generate(12, (index) => random[DateTime.now().microsecond % random.length]).join();
    setState(() {
      _qrData = randomNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Código QR'),
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
          style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildQrDisplay(TextTheme textTheme, String data) {
    return Container(
      key: ValueKey(data), // Use data as key to trigger animation
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Código Generado',
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
          ),
        ],
      ),
    );
  }
}
