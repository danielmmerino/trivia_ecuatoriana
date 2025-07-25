import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/question.dart';
import '../models/category.dart';
import '../services/question_service.dart';

class PreguntasScreen extends StatefulWidget {
  const PreguntasScreen({
    super.key,
    this.categoryId,
    this.category,
    this.categories,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.questionNumber = 1,
    this.totalQuestions = 10,
  });

  final int? categoryId;
  final Category? category; // <--- agregada
  final List<Category>? categories;
  final int correctCount;
  final int incorrectCount;
  final int questionNumber;
  final int totalQuestions;

  @override
  State<PreguntasScreen> createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends State<PreguntasScreen>
    with TickerProviderStateMixin {
  late Future<Question> _futureQuestion;
  bool _showLoading = true;
  bool _showCorrect = false;
  bool _showIncorrect = false;
  bool _showCorrectAnswer = false;
  Option? _correctOption;
  late AnimationController _controller;
  late AnimationController _timerController;
  late AnimationController _loadingController;
  bool _timerStarted = false;
  Question? _currentQuestion;
  late final AudioPlayer _audioPlayer;
  late Category _currentCategory;
  late int _correctCount;
  late int _incorrectCount;
  late int _questionNumber;
  late int _totalQuestions;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _correctCount = widget.correctCount;
    _incorrectCount = widget.incorrectCount;
    _questionNumber = widget.questionNumber;
    _totalQuestions = widget.totalQuestions;
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      _currentCategory =
          widget.categories![Random().nextInt(widget.categories!.length)];
    } else {
      _currentCategory = widget.category!;
    }
    _loadQuestion();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onTimeExpired();
        }
      });
    _loadingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _audioPlayer = AudioPlayer();
  }

  Future<Question> _fetchQuestion() async {
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      _currentCategory =
          widget.categories![Random().nextInt(widget.categories!.length)];
    }
    final questions =
        await QuestionService().fetchQuestions(_currentCategory.id);
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

  Future<void> _loadQuestion() async {
    setState(() {
      _showLoading = true;
      _timerStarted = false;
      _currentQuestion = null;
      _futureQuestion = _fetchQuestion();
    });
    await _futureQuestion;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _showLoading = false;
    });
  }

  void _onOptionSelected(Option selected, Option correct) {
    _timerController.stop();
    _timerController.reset();
    final isCorrect = selected.esCorrecta;
    if (isCorrect) {
      _playSound('sounds/correct.wav');
      _correctCount++;
      setState(() {
        _showCorrect = true;
        _showIncorrect = false;
        _showCorrectAnswer = false;
        _correctOption = null;
      });
    } else {
      _playSound('sounds/incorrect.wav');
      _incorrectCount++;
      setState(() {
        _showIncorrect = true;
        _showCorrect = false;
        _showCorrectAnswer = true;
        _correctOption = correct;
      });
    }
    _controller.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_questionNumber >= _totalQuestions) {
        setState(() => _quizFinished = true);
      } else {
        setState(() {
          _questionNumber++;
          _showCorrect = false;
          _showIncorrect = false;
          _showCorrectAnswer = false;
          _correctOption = null;
        });
        _loadQuestion();
      }
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

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _loadingController,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/${_currentCategory.icono}'),
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Cargando...'),
        ],
      ),
    );
  }

  void _onTimeExpired() {
    if (_showCorrect || _showIncorrect || _currentQuestion == null) return;
    final correct = _currentQuestion!.opciones.firstWhere((o) => o.esCorrecta);
    final incorrect =
        _currentQuestion!.opciones.firstWhere((o) => !o.esCorrecta);
    _onOptionSelected(incorrect, correct);
  }

  Widget _buildTimerBar() {
    return AnimatedBuilder(
      animation: _timerController,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: 1 - _timerController.value,
          minHeight: 5,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timerController.dispose();
    _loadingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quizFinished) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/${_currentCategory.icono}'),
              ),
              const SizedBox(width: 8),
              Text(widget.categories != null
                  ? 'Trivia Aleatoria'
                  : _currentCategory.nombre),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡Trivia finalizada!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text('Correctas: $_correctCount',
                  style: const TextStyle(fontSize: 20)),
              Text('Incorrectas: $_incorrectCount',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/${_currentCategory.icono}'),
            ),
            const SizedBox(width: 8),
            Text(widget.categories != null
                ? 'Trivia Aleatoria'
                : _currentCategory.nombre),
          ],
        ),
      ),
      body: FutureBuilder<Question>(
        future: _futureQuestion,
        builder: (context, snapshot) {
          if (_showLoading || !snapshot.hasData) {
            return _buildLoading();
          }
          final question = snapshot.data!;
          _currentQuestion = question;
          if (!_timerStarted) {
            _timerStarted = true;
            _timerController.forward(from: 0.0);
          }
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTimerBar(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_totalQuestions > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pregunta $_questionNumber de $_totalQuestions',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Correctas: $_correctCount  Incorrectas: $_incorrectCount',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
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
