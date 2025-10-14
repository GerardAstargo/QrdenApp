import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'qr_generator_screen.dart';
import 'profile_screen.dart';
import 'services/firestore_service.dart';
import 'models/product_model.dart';
import 'scanner_screen.dart';
import 'product_detail_screen.dart';
import 'widgets/category_display_widget.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _fabAnimationController;

  String _welcomeMessage = 'Bienvenido';
  String _searchQuery = '';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null && mounted) {
      final employee = await _firestoreService.getEmployeeByEmail(user.email!);
      if (mounted && employee != null) {
        setState(() {
          _welcomeMessage = 'BIENVENIDO, ${employee.nombre.toUpperCase()}';
        });
      } else if (mounted) {
        setState(() {
          _welcomeMessage = 'Bienvenido';
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProducts();
    });
  }

  void _filterProducts() {
    final products = _allProducts;
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(products);
    } else {
      _filteredProducts = products
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
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

  void _navigateAndScan(ScanMode mode) async {
    if (_isFabMenuOpen) {
      _toggleFabMenu();
    }
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => ScannerScreen(scanMode: mode)),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToQrGenerator() {
    if (_isFabMenuOpen) {
      _toggleFabMenu();
    }
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: const Key('homeScreenScaffold'),
      appBar: _buildAppBar(context, themeProvider),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              _welcomeMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildProductList()),
        ],
      ),
      floatingActionButton: _buildExpandableFab(context),
    );
  }

  AppBar _buildAppBar(BuildContext context, ThemeProvider themeProvider) {
    return AppBar(
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(150),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            hintText: 'Buscar en el inventario...',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          tooltip: 'Cambiar Tema',
          onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
        ),
        IconButton(
          icon: const Icon(Icons.history_outlined),
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
          return Center(child: Text('Error al cargar productos: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Tu inventario está vacío',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '¡Añade un producto para empezar!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        _allProducts = snapshot.data!;
        _filterProducts();

        if (_filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron productos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'No hay productos que coincidan con "$_searchQuery".',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 70.0,
                  child: FadeInAnimation(
                    child: Card(
                      elevation: 3.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.qr_code_scanner_rounded,
                              color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                        title: Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                        subtitle: CategoryDisplayWidget(categoryReference: product.category),
                        trailing: Text('Stock: ${product.quantity}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary)),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product)),
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
              color: Colors.black.withAlpha(150),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ..._buildFabMenuItems(),
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

  List<Widget> _buildFabMenuItems() {
    final actions = [
      FabAction(icon: Icons.add_to_photos_outlined, label: 'Añadir', onPressed: () => _navigateAndScan(ScanMode.add)),
      FabAction(icon: Icons.remove_from_queue_outlined, label: 'Eliminar', onPressed: () => _navigateAndScan(ScanMode.remove)),
      FabAction(icon: Icons.edit_note_outlined, label: 'Modificar', onPressed: () => _navigateAndScan(ScanMode.update)),
      FabAction(icon: Icons.qr_code_2_sharp, label: 'Generar QR', onPressed: _navigateToQrGenerator),
    ];

    return List.generate(actions.length, (index) {
      return AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          final bottom = 70.0 + (index * 65.0) * _fabAnimationController.value;
          return Positioned(
            right: 8.0,
            bottom: bottom,
            child: Opacity(
              opacity: _fabAnimationController.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFabMenuOpen)
                    Card(
                      elevation: 2,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(actions[index].label, style: Theme.of(context).textTheme.labelLarge))),
                  const SizedBox(width: 12),
                  FloatingActionButton.small(
                    heroTag: 'fab_action_$index',
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
