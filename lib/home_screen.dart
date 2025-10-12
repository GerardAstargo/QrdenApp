import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import './qr_generator_screen.dart';
import './profile_screen.dart';
import './firestore_service.dart';
import './product_model.dart';
import './scanner_screen.dart';
import './product_detail_screen.dart';
import './category_display_widget.dart';
import './history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  String _welcomeMessage = 'Bienvenido';
  late AnimationController _fabAnimationController;
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() {
        final displayName = user.displayName;
        _welcomeMessage = (displayName != null && displayName.isNotEmpty) ? 'Hola, $displayName' : 'Bienvenido';
      });
    }
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
      if (_isFabMenuOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  // --- REVERTED: Navigate with specific ScanMode ---
  void _navigateAndScan(ScanMode mode) async {
    _toggleFabMenu(); 
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => ScannerScreen(scanMode: mode)),
    );

    if (result != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(result), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _navigateToQrGenerator() {
    _toggleFabMenu();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QrGeneratorScreen()),
    );
  }

  void _navigateToHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_welcomeMessage),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
            onPressed: _navigateToHistory,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: _buildProductList(),
      floatingActionButton: _buildExpandableFab(context),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: _firestoreService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Tu inventario está vacío.\n¡Añade un producto para empezar!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final products = snapshot.data!;
        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    // --- REVERTED: No Dismissible, direct navigation ---
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
                          child: Icon(Icons.qr_code_scanner, color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: CategoryDisplayWidget(categoryReference: product.category),
                        trailing: Text('Stock: ${product.quantity}', style: Theme.of(context).textTheme.titleMedium),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildExpandableFab(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isFabMenuOpen)
          GestureDetector(
            onTap: _toggleFabMenu,
            child: Container(
              color: Colors.black.withAlpha(128),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ..._buildFabMenuItems(),
        FloatingActionButton(
          onPressed: _toggleFabMenu,
          elevation: 4,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _fabAnimationController,
          ),
        ),
      ],
    );
  }

  // --- REVERTED: Add, Remove, Search actions ---
  List<Widget> _buildFabMenuItems() {
    final actions = [
      FabAction(icon: Icons.add_to_photos_outlined, label: 'Añadir Stock', onPressed: () => _navigateAndScan(ScanMode.add)),
      FabAction(icon: Icons.remove_from_queue_outlined, label: 'Quitar Stock', onPressed: () => _navigateAndScan(ScanMode.remove)),
      FabAction(icon: Icons.search_outlined, label: 'Buscar Producto', onPressed: () => _navigateAndScan(ScanMode.search)),
      FabAction(icon: Icons.qr_code_2_sharp, label: 'Generar QR', onPressed: _navigateToQrGenerator),
    ];

    return List.generate(actions.length, (index) {
      return AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          final bottom = 65.0 + (index * 60.0) * _fabAnimationController.value;
          return Positioned(
            right: 4.0,
            bottom: bottom,
            child: Opacity(
              opacity: _fabAnimationController.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(actions[index].label))),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: actions[index].onPressed,
                    child: Icon(actions[index].icon),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }).reversed.toList();
  }
}

class FabAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  FabAction({required this.icon, required this.label, required this.onPressed});
}
