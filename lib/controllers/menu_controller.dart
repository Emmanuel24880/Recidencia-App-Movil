import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firebase_service.dart';

class MenuAppController extends ChangeNotifier {
  Stream<List<Producto>>? _productosStream;
  String _mesaActual = '';
  String _error = '';

  Stream<List<Producto>>? get productosStream => _productosStream;
  String get mesaActual => _mesaActual;
  String get error => _error;

  void inicializar(String mesaId) {
    _mesaActual = mesaId;
    _productosStream = FirebaseService.streamProductosActivos();
    notifyListeners();
  }

  Future<void> agregarAlCarrito(Producto producto, int cantidad) async {
    // TODO: lógica carrito local
    debugPrint('Agregar ${producto.nombre} x$cantidad');
  }

  List<Producto> filtrarPorCategoria(List<Producto> todos, String categoria) {
    return todos.where((p) => p.categoria == categoria).toList();
  }
}
