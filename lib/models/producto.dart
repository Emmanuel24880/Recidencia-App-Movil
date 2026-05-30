class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String imagenUrl;
  final double precio;
  final int stock;
  final bool activo;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.imagenUrl,
    required this.precio,
    required this.stock,
    required this.activo,
  });

  factory Producto.fromMap(Map<String, dynamic> map, String documentId) {
    return Producto(
      id: map['id'] ?? documentId,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      categoria: map['categoria'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0) is int
          ? map['stock'] ?? 0
          : int.tryParse(map['stock'].toString()) ?? 0,
      activo: map['activo'] ?? false,
    );
  }
}
