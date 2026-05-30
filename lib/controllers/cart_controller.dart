import 'package:flutter/material.dart';
import '../models/carrito.dart';
import '../models/producto.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// 🔥 MESA ACTUAL
  int? mesa;

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// 🔥 SETEAR MESA
  void setMesa(int mesaSeleccionada) {
    mesa = mesaSeleccionada;
    notifyListeners();
  }

  void addToCart(Producto producto) {
    final index = _items.indexWhere((e) => e.producto.id == producto.id);

    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(CartItem(producto: producto));
    }

    notifyListeners();
  }

  void increase(String productId) {
    final index = _items.indexWhere((e) => e.producto.id == productId);
    if (index >= 0) {
      _items[index].cantidad++;
      notifyListeners();
    }
  }

  void decrease(String productId) {
    final index = _items.indexWhere((e) => e.producto.id == productId);
    if (index >= 0) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void remove(String productId) {
    _items.removeWhere((e) => e.producto.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Map<String, dynamic>? user;

  void setUser(Map<String, dynamic> userData) {
    user = userData;
  }
}
