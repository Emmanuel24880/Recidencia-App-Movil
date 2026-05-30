import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CobroView extends StatelessWidget {
  const CobroView({super.key});

  /// 🔥 OBTENER ÓRDENES
  /// ELIMINA AUTOMÁTICAMENTE LOS PEDIDOS PAGADOS
  /// DESPUÉS DE 24 HORAS
  Stream<QuerySnapshot> getOrdenes() {
    return FirebaseFirestore.instance
        .collection('ordenes')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  /// 🔥 MARCAR COMO PAGADO
  Future<void> marcarPagado(String docId) async {
    await FirebaseFirestore.instance.collection('ordenes').doc(docId).update({
      "estado": "pagado",
      "fechaPago": Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 10, 10),

      appBar: AppBar(
        title: const Text("Cobro de mesa"),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.amber,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getOrdenes(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ahora = DateTime.now();

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['fecha'] == null) {
              return false;
            }

            final fecha = (data['fecha'] as Timestamp).toDate();

            return fecha.year == ahora.year &&
                fecha.month == ahora.month &&
                fecha.day == ahora.day;
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay órdenes",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView(
            children: (() {
              docs.sort((a, b) {
                final estadoA = (a['estado'] ?? '');
                final estadoB = (b['estado'] ?? '');

                if (estadoA == estadoB) return 0;

                if (estadoA == 'pendiente') return -1;

                return 1;
              });

              return docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                return _ordenCard(context, doc.id, data);
              }).toList();
            })(),
          );
        },
      ),

      /// 🔥 BOTTOM BAR
      bottomNavigationBar: _bottomBar(context),
    );
  }

  Widget _ordenCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final productos = List.from(data['productos'] ?? []);

    final estado = data['estado'] ?? "pendiente";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade600),

          bottom: BorderSide(color: Colors.grey.shade600),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 PEDIDO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Pedido",

                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

              Text(
                "Total: \$${data['total']}",

                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔥 PRODUCTOS
          ...productos.map((p) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  "${p['nombre']} x${p['cantidad']}",

                  style: const TextStyle(color: Colors.white70),
                ),

                Text(
                  "\$${p['precio']}",

                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            );
          }),

          const SizedBox(height: 15),

          /// 🔥 ESTADO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "Mesa ${data['mesa']}",

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              estado == "pendiente"
                  ? ElevatedButton(
                      onPressed: () => marcarPagado(docId),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),

                      child: const Text("Por pagar"),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Text(
                        "Pagado",

                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
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
            onTap: () => context.goNamed('home'),

            child: const Icon(Icons.home),
          ),

          GestureDetector(
            onTap: () => context.pushNamed('cartview'),

            child: const Icon(Icons.shopping_cart),
          ),

          GestureDetector(
            onTap: () {
              context.pushNamed('cobro');
            },

            child: const Icon(Icons.receipt_long),
          ),
        ],
      ),
    );
  }
}
