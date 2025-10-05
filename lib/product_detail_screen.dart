import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import './product_model.dart';
import './category_display_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return DateFormat('d MMMM y, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildHeaderCard(context, textTheme),
              _buildDetailCard(
                context: context,
                icon: Icons.qr_code,
                label: 'Código de Producto',
                value: product.id,
              ),
              _buildDetailCard(
                context: context,
                icon: Icons.category_outlined,
                label: 'Categoría',
                child: CategoryDisplayWidget(categoryReference: product.category, style: textTheme.titleMedium),
              ),
              _buildDetailCard(
                context: context,
                icon: Icons.inventory_2_outlined,
                label: 'Cantidad en Stock',
                value: product.quantity.toString(),
              ),
              _buildDetailCard(
                context: context,
                icon: Icons.price_change_outlined,
                label: 'Precio',
                value: '\$${product.price.toStringAsFixed(2)}',
              ),
              _buildDetailCard(
                context: context,
                icon: Icons.person_outline,
                label: 'Ingresado por',
                value: product.enteredBy ?? 'No disponible',
              ),
              _buildDetailCard(
                context: context,
                icon: Icons.calendar_today_outlined,
                label: 'Fecha de Ingreso',
                value: _formatDate(product.fechaIngreso?.toDate()),
              ),
              _buildDetailCard(
                context: context,
                icon: Icons.business_outlined, // Icon for "Shelf Number"
                label: 'Número de Estante',
                value: product.numeroEstante?.toString() ?? 'No especificado',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withAlpha(25), // Modern way to set opacity
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          product.name,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? value,
    Widget? child,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withAlpha(25), // Modern way to set opacity
              foregroundColor: colorScheme.primary,
              child: Icon(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  child ?? 
                  Text(
                    value ?? '',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
