class Option {
  final int orden;
  final String opcion;
  final bool esCorrecta;

  Option({required this.orden, required this.opcion, required this.esCorrecta});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      orden: int.parse(json['orden'].toString()),
      opcion: json['opcion'] as String,
      esCorrecta: json['esCorrecta'].toString().toLowerCase() == 'true',
    );
  }
}

class Question {
  final String pregunta;
  final List<Option> opciones;

  Question({required this.pregunta, required this.opciones});

  factory Question.fromJson(Map<String, dynamic> json) {
    final opcionesJson = json['opciones'] as List<dynamic>;
    return Question(
      pregunta: json['pregunta'] as String,
      opciones: opcionesJson.map((e) => Option.fromJson(e)).toList(),
    );
  }
}
