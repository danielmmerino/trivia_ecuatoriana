class Category {
  final int id;
  final String nombre;
  final String icono;
  final int estado;

  Category({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.estado,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      icono: json['icono'] as String,
      estado: json['estado'] as int,
    );
  }
}
