import 'package:app_movil_1/controllers/cart_controller.dart';
import 'package:app_movil_1/controllers/mesa_controller.dart';
import 'package:app_movil_1/models/producto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProductView extends StatelessWidget {
  final Producto producto;

  const ProductView({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.amber),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: producto.imagenUrl.isNotEmpty
                              ? Image.network(
                                  producto.imagenUrl,
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 130,
                                      height: 130,
                                      color: Colors.grey.shade800,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 130,
                                  height: 130,
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              producto.nombre,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Precio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${producto.precio.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Descripcion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      producto.descripcion.isEmpty
                          ? 'Sin descripción disponible.'
                          : producto.descripcion,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Categoría: ${producto.categoria}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stock disponible: ${producto.stock}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final mesaCtrl = context.read<MesaController>();
                          final cartCtrl = context.read<CartController>();

                          // ❌ Si no hay mesa seleccionada
                          if (mesaCtrl.mesaSeleccionada == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Selecciona una mesa primero"),
                              ),
                            );
                            return;
                          }

                          // 🔥 Asignar mesa al carrito
                          cartCtrl.setMesa(mesaCtrl.mesaSeleccionada!);

                          // 🔥 Agregar producto
                          cartCtrl.addToCart(producto);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text(
                                    'Producto agregado',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Añadir',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      final cart = context.read<CartController>();
                      context.goNamed('home', extra: cart.user);
                    },
                    child: const Icon(Icons.home),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.goNamed('cartview');
                    },
                    child: const Icon(Icons.shopping_cart),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.goNamed('cobro');
                    },
                    child: const Icon(Icons.receipt_long),
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
