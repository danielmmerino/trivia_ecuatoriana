import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/question_service.dart';

class PreguntasScreen extends StatefulWidget {
  const PreguntasScreen({super.key, required this.categoryId});

  final int categoryId;

  @override
  State<PreguntasScreen> createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends State<PreguntasScreen>
    with SingleTickerProviderStateMixin {
  late Future<Question> _futureQuestion;
  bool _showCorrect = false;
  bool _showIncorrect = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _futureQuestion = _fetchQuestion();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<Question> _fetchQuestion() async {
    final questions = await QuestionService().fetchQuestions(widget.categoryId);
    if (questions.isEmpty) {
      throw Exception('Sin preguntas disponibles');
    }
    return questions.first;
  }

  void _onOptionSelected(Option option) {
    if (option.esCorrecta) {
      setState(() {
        _showCorrect = true;
        _showIncorrect = false;
      });
    } else {
      setState(() {
        _showIncorrect = true;
        _showCorrect = false;
      });
    }
    _controller.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pop(context, option.esCorrecta);
    });
  }

  Widget _buildCorrectAnimation() {
    return _showCorrect
        ? Center(
            child: ScaleTransition(
              scale: _controller,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle,
                      size: 80, color: Colors.green),
                  SizedBox(height: 8),
                  Text(
                    'Respuesta correcta',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildIncorrectAnimation() {
    return _showIncorrect
        ? Center(
            child: ScaleTransition(
              scale: _controller,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.cancel, size: 80, color: Colors.red),
                  SizedBox(height: 8),
                  Text(
                    'Respuesta incorrecta',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregunta'),
      ),
      body: FutureBuilder<Question>(
        future: _futureQuestion,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final question = snapshot.data!;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.pregunta,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ...question.opciones.map((option) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _onOptionSelected(option),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(option.opcion),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              _buildCorrectAnimation(),
              _buildIncorrectAnimation(),
            ],
          );
        },
      ),
    );
  }
}
