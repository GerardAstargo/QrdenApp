import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './qr_generator_screen.dart';
import './profile_screen.dart';
import './firestore_service.dart';
import './product_model.dart';
import './scanner_screen.dart';
import './product_detail_screen.dart';
import './category_display_widget.dart'; // Import the new widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _welcomeMessage = 'Bienvenido';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          final displayName = user.displayName;
          if (displayName != null && displayName.isNotEmpty) {
            _welcomeMessage = 'Bienvenido, $displayName';
          }
        });
      }
    }
  }

  void _navigateAndScan(ScanMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ScannerScreen(scanMode: mode)),
    );
  }

  void _navigateToQrGenerator() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QrGeneratorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_welcomeMessage), // Dynamic welcome message
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildActionButtons(context),
          const Divider(thickness: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Inventario Actual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.add_to_photos_outlined,
            label: 'Añadir Producto',
            color: Theme.of(context).primaryColor,
            onPressed: () => _navigateAndScan(ScanMode.add),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.remove_from_queue_outlined,
            label: 'Eliminar Producto',
            color: Colors.red,
            onPressed: () => _navigateAndScan(ScanMode.remove),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.edit_note_outlined,
            label: 'Modificar Producto',
            color: Colors.orange,
            onPressed: () => _navigateAndScan(ScanMode.update),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.qr_code_2_sharp,
            label: 'Generar Código QR',
            color: Colors.green,
            onPressed: _navigateToQrGenerator,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 24),
              Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
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
          // Display a more informative error message in the UI
          return Center(child: Text('Error al cargar productos: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay productos en el inventario.'));
        }

        final products = snapshot.data!;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner, size: 40),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                // Use the new widget to display the category name
                subtitle: CategoryDisplayWidget(categoryReference: product.category),
                trailing: Text('Stock: ${product.quantity}', style: Theme.of(context).textTheme.titleMedium),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
