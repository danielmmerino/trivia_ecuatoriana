import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  bool _showCorrectAnswer = false;
  Option? _correctOption;
  late AnimationController _controller;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _futureQuestion = _fetchQuestion();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _audioPlayer = AudioPlayer();
  }

  Future<Question> _fetchQuestion() async {
    final questions = await QuestionService().fetchQuestions(widget.categoryId);
    if (questions.isEmpty) {
      throw Exception('Sin preguntas disponibles');
    }
    return questions.first;
  }

  Future<void> _playSound(String asset) async {
    try {
      await _audioPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  void _onOptionSelected(Option selected, Option correct) {
    if (selected.esCorrecta) {
      _playSound('sounds/correct.wav');
      setState(() {
        _showCorrect = true;
        _showIncorrect = false;
        _showCorrectAnswer = false;
        _correctOption = null;
      });
    } else {
      _playSound('sounds/incorrect.wav');
      setState(() {
        _showIncorrect = true;
        _showCorrect = false;
        _showCorrectAnswer = true;
        _correctOption = correct;
      });
    }
    _controller.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pop(context, selected.esCorrecta);
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
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
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

  Widget _buildIncorrectWithAnswerAnimation() {
    return _showIncorrect
        ? Center(
            child: ScaleTransition(
              scale: _controller,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel, size: 80, color: Colors.red),
                  const SizedBox(height: 8),
                  const Text(
                    'Respuesta incorrecta',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Correcta: ${_correctOption?.opcion ?? ''}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
                      final correctOption =
                          question.opciones.firstWhere((e) => e.esCorrecta);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () =>
                              _onOptionSelected(option, correctOption),
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
              _buildIncorrectWithAnswerAnimation(),
            ],
          );
        },
      ),
    );
  }
}
