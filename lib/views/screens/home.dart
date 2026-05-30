import 'package:app_movil_1/controllers/cart_controller.dart';
import 'package:app_movil_1/controllers/mesa_controller.dart';
import 'package:app_movil_1/models/producto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final cartCtrl = context.read<CartController>();
    cartCtrl.setUser(widget.user);
    _escucharPedidosListos();
  }

  final List<String> categories = ["Popular", "Desayuno", "Comida", "Bebida"];

  String selectedCategory = "Popular";

  List<Map<String, dynamic>> notificaciones = [];

  String getFirstName(String nombreCompleto) {
    return nombreCompleto.split(" ").first;
  }

  Stream<List<Producto>> getProductos() {
    Query query = FirebaseFirestore.instance
        .collection('producto')
        .where('activo', isEqualTo: true);

    if (selectedCategory != "Popular") {
      query = query.where('categoria', isEqualTo: selectedCategory);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  void _escucharPedidosListos() {
    FirebaseFirestore.instance
        .collection('ordenes')
        .where('meseroNombre', isEqualTo: widget.user['nombre'])
        .where('estadoCocina', isEqualTo: 'listo')
        .snapshots()
        .listen((snapshot) {
          final ahora = DateTime.now();

          final docs = snapshot.docs.where((doc) {
            final data = doc.data();

            if (data['fecha'] == null) {
              return true;
            }

            final fecha = (data['fecha'] as Timestamp).toDate();

            final diferencia = ahora.difference(fecha);

            /// SOLO 10 MINUTOS
            return diferencia.inMinutes < 10;
          }).toList();

          setState(() {
            notificaciones = docs.map((doc) {
              final data = doc.data();

              return {
                'id': doc.id,

                'mesa': data['mesa'],

                'productos': data['productos'],

                'vista': data['notificacionVista'] ?? false,

                'fecha': data['fecha'],
              };
            }).toList();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _content()),
            _bottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFB300),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          /// 🔥 TEXTO DINÁMICO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hola ${getFirstName(widget.user['nombre'])}, ${widget.user['mesero']}!!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _notificationBell(),

                  const SizedBox(height: 8),

                  _mesasSelector(),
                ],
              ),
            ],
          ),

          const SizedBox(height: 5),
          const Text(
            "Te deseamos un buen día de trabajo",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: "Buscar",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _categories(),
          const SizedBox(height: 15),
          Expanded(child: _grid()),
        ],
      ),
    );
  }

  Widget _categories() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _grid() {
    return StreamBuilder<List<Producto>>(
      stream: getProductos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final productos = snapshot.data ?? [];

        if (productos.isEmpty) {
          return const Center(
            child: Text(
              'No hay productos disponibles',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return GridView.builder(
          itemCount: productos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final producto = productos[index];
            return _productCard(producto);
          },
        );
      },
    );
  }

  Widget _productCard(Producto producto) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('productview', extra: producto);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: producto.imagenUrl.isNotEmpty
                    ? Image.network(
                        producto.imagenUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.fastfood,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producto.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${producto.precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mesasSelector() {
    return Consumer<MesaController>(
      builder: (context, mesaCtrl, _) {
        if (mesaCtrl.mesas.isEmpty) {
          return const SizedBox();
        }

        final mesaActual = mesaCtrl.mesaSeleccionada ?? mesaCtrl.mesas.first;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,

          children: [
            /// 🔥 TEXTO
            const Text(
              "Mesa",

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(width: 10),

            /// 🔥 SELECTOR
            PopupMenuButton<int>(
              onSelected: (mesa) {
                mesaCtrl.seleccionarMesa(mesa);
              },

              itemBuilder: (context) {
                return mesaCtrl.mesas.map((mesa) {
                  final isSelected = mesa == mesaActual;

                  return PopupMenuItem<int>(
                    value: mesa,

                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),

                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check, color: Colors.green),

                          if (isSelected) const SizedBox(width: 8),

                          Text(
                            "Mesa $mesa",

                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    Text(
                      "$mesaActual",

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 6),

                    const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _notificationBell() {
    return GestureDetector(
      onTap: () {
        for (var notif in notificaciones) {
          if (notif['vista'] == false) {
            FirebaseFirestore.instance
                .collection('ordenes')
                .doc(notif['id'])
                .update({'notificacionVista': true});
          }
        }
        showModalBottomSheet(
          context: context,

          backgroundColor: const Color(0xFF1E1E1E),

          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),

          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Center(
                    child: Text(
                      "Pedidos listos 🍽️",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: notificaciones.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay pedidos listos",

                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: notificaciones.length,

                            itemBuilder: (context, index) {
                              final notif = notificaciones[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),

                                padding: const EdgeInsets.all(16),

                                decoration: BoxDecoration(
                                  color: Colors.grey[900],

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Mesa ${notif['mesa']}",

                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    ...(notif['productos'] as List).map((p) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),

                                        child: Text(
                                          "• ${p['nombre']} x${p['cantidad']}",

                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },

      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.black,

              borderRadius: BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.notifications,

              color: Colors.amber,
              size: 28,
            ),
          ),

          if (notificaciones.where((n) => n['vista'] == false).isNotEmpty)
            Positioned(
              right: 0,
              top: 0,

              child: Container(
                width: 22,
                height: 22,

                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),

                child: Center(
                  child: Text(
                    "${notificaciones.where((n) => n['vista'] == false).length}",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(12),

      padding: const EdgeInsets.symmetric(vertical: 10),

      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          const Icon(Icons.home),
          GestureDetector(
            onTap: () {
              context.go('/qr', extra: widget.user);
            },

            child: const Icon(Icons.qr_code_scanner),
          ),
          GestureDetector(
            onTap: () {
              context.pushNamed('cartview');
            },

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
