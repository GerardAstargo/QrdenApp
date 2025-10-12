import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animations/animations.dart';

import './product_model.dart';
import './firestore_service.dart';
import './product_detail_screen.dart';
import './scanner_screen.dart';
import './profile_screen.dart';
import './history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
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

  void _navigateToScanner(BuildContext context, String scanMode) {
    _toggleFabMenu();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(scanMode: scanMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos en el inventario.'));
          }

          final products = snapshot.data!;

          return AnimationLimiter(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildProductCard(context, product),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      closedElevation: 2.0,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).cardColor,
      closedBuilder: (context, action) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(product.name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text('Stock: ${product.quantity}'),
          trailing: const Icon(Icons.chevron_right),
        );
      },
      openBuilder: (context, action) {
        return ProductDetailScreen(product: product);
      },
    );
  }

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabMenuOpen)
          ..._buildMenuButtons(),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggleFabMenu,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _fabAnimationController,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuButtons() {
    return [
      _buildMiniFab(
        icon: Icons.add,
        label: 'Añadir Stock',
        onPressed: () => _navigateToScanner(context, 'update'),
      ),
      const SizedBox(height: 12),
      _buildMiniFab(
        icon: Icons.qr_code_scanner,
        label: 'Nuevo Producto',
        onPressed: () => _navigateToScanner(context, 'add'),
      ),
    ];
  }

  Widget _buildMiniFab({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: onPressed,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }
}
