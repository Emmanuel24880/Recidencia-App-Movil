import 'package:flutter/material.dart';

class MesaController extends ChangeNotifier {
  final List<int> _mesas = [1, 2, 3];
  int? _mesaSeleccionada;

  List<int> get mesas => _mesas;
  int? get mesaSeleccionada => _mesaSeleccionada;

  void agregarMesa(int mesa) {
    if (!_mesas.contains(mesa)) {
      _mesas.add(mesa);
      notifyListeners();
    }
  }

  void seleccionarMesa(int mesa) {
    _mesaSeleccionada = mesa;
    notifyListeners();
  }
}
