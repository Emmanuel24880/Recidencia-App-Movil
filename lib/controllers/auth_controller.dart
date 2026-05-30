import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> login(String telefono, String password) async {
    try {
      print("📱 Telefono ingresado: $telefono");

      final query = await _db
          .collection('mesero')
          .where('telefono', isEqualTo: telefono)
          .limit(1)
          .get();

      print("📊 Docs encontrados: ${query.docs.length}");

      if (query.docs.isEmpty) {
        print("❌ Usuario no encontrado");
        return null;
      }

      final data = query.docs.first.data();

      print("📦 Data: $data");

      // Validar contraseña
      if (data['contraseña'] != password) {
        print("❌ Contraseña incorrecta");
        return null;
      }

      // Validar estado
      if (data['estado'] != true) {
        print("❌ Usuario inactivo");
        return null;
      }

      print("✅ LOGIN EXITOSO");

      // 🔥 REGRESAMOS SOLO LO NECESARIO
      return {
        "nombre": data['nombre'],
        "mesero": data['mesero'], // 👈 M1, M2, etc.
        "telefono": data['telefono'],
      };
    } catch (e) {
      print('🔥 ERROR: $e');
      return null;
    }
  }
}
