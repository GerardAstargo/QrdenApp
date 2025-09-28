import 'package:flutter/material.dart';
import './firestore_service.dart';
import './product_model.dart';
import './scanner_screen.dart';
import './profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Bodega'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildActions(context),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: firestoreService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay productos en la bodega.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                final products = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26), // <--- Deprecation fix
                          child: Icon(
                            Icons.qr_code_2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(product.description),
                        trailing: Text(
                          'Cant: ${product.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
        children: [
          _buildActionCard(
            context,
            icon: Icons.add_shopping_cart_outlined,
            label: 'Añadir',
            onTap: () => _navigateToScanner(context, ScanMode.add),
          ),
          _buildActionCard(
            context,
            icon: Icons.remove_shopping_cart_outlined,
            label: 'Eliminar',
            onTap: () => _navigateToScanner(context, ScanMode.remove),
          ),
          _buildActionCard(
            context,
            icon: Icons.edit_outlined,
            label: 'Modificar',
            onTap: () => _navigateToScanner(context, ScanMode.update),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }

  void _navigateToScanner(BuildContext context, ScanMode mode) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ScannerScreen(scanMode: mode),
    ));
  }
}
