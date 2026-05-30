import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/producto.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream que escucha productos en tiempo real
  static Stream<List<Producto>> streamProductosActivos() {
    return _db
        .collection('productos')
        .where('estado', isEqualTo: 'activo')
        .orderBy('categoria')
        .orderBy('nombre')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Producto.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Crear pedido (mesero)
  static Future<void> crearPedido({
    required String mesaId,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    await _db.collection('pedidos').add({
      'mesaId': mesaId,
      'items': items,
      'total': total,
      'estado': 'pendiente',
      'fecha': FieldValue.serverTimestamp(),
      'meseroId': FirebaseAuth.instance.currentUser?.uid,
    });
  }
}
