import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  IconButton(
                    onPressed: () => context.pop(),

                    icon: const Icon(Icons.arrow_back, color: Colors.amber),
                  ),

                  const Text(
                    'Pedidos',

                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Container(
                    width: 42,
                    height: 42,

                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
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
              child: cart.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Tu carrito está vacío',

                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _pedidoCard(
                            context,
                            cart,
                            cart.mesa != null
                                ? "Mesa ${cart.mesa}"
                                : "Sin mesa",
                          ),
                        ],
                      ),
                    ),
            ),

            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _pedidoCard(BuildContext context, CartController cart, String mesa) {
    final comentarioController = TextEditingController();

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade400, width: 1),

          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Pedido',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.cantidad > 1
                                    ? '${item.producto.nombre} x${item.cantidad}'
                                    : item.producto.nombre,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            Text(
                              '\$${item.subtotal.toStringAsFixed(0)}',

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Total : ${cart.total.toStringAsFixed(0)}',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Enviar a cocina',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: 120,
                    height: 42,

                    child: ElevatedButton(
                      onPressed: () {
                        enviarPedido(context, cart, comentarioController.text);
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),

                      child: const Text(
                        'Enviar',

                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  /// 🔥 BOTÓN COMENTARIOS
                  const SizedBox(height: 12),

                  SizedBox(
                    width: 120,
                    height: 42,

                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,

                          builder: (_) {
                            return AlertDialog(
                              backgroundColor: Colors.grey.shade900,

                              title: const Text(
                                "Comentario",

                                style: TextStyle(color: Colors.white),
                              ),

                              content: TextField(
                                controller: comentarioController,

                                maxLines: 4,

                                style: const TextStyle(color: Colors.white),

                                decoration: InputDecoration(
                                  hintText: "Agregar comentario",

                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.amber),
                                  ),
                                ),
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },

                                  child: const Text(
                                    "Guardar",

                                    style: TextStyle(color: Colors.amber),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),

                      child: const Text('Comentarios'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            mesa,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> enviarPedido(
    BuildContext context,
    CartController cart,
    String comentario,
  ) async {
    if (cart.mesa == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecciona una mesa")));

      return;
    }

    try {
      /// 🔥 PRODUCTOS
      final productos = cart.items.map((item) {
        return {
          "nombre": item.producto.nombre,
          "cantidad": item.cantidad,
          "precio": item.producto.precio,
        };
      }).toList();

      /// 🔥 GUARDAR EN FIREBASE
      await FirebaseFirestore.instance.collection('ordenes').add({
        "estado": "pendiente",
        "fecha": Timestamp.now(),
        "mesa": cart.mesa,
        "meseroNombre": cart.user?['nombre'] ?? "Desconocido",
        "productos": productos,
        "total": cart.total,
        "comentario": comentario,
      });

      /// 🔥 LIMPIAR CARRITO
      cart.clear();

      /// 🔥 PALOMA VERDE 1 SEGUNDO
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),

          backgroundColor: Colors.green,

          content: const Row(
            children: [
              Icon(Icons.check, color: Colors.white),

              SizedBox(width: 10),

              Text("Pedido enviado", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _bottomBar(BuildContext context) {
    final cart = context.read<CartController>();
    return Container(
      margin: const EdgeInsets.all(14),

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
    );
  }
}
