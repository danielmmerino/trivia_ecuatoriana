import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'preguntas_screen.dart';

/// Screen that displays a roulette style wheel with different trivia
/// categories. When the wheel is tapped it spins and stops on a random
/// category loaded from a json file.
class CategoryRandomScreen extends StatefulWidget {
  const CategoryRandomScreen({super.key});

  @override
  State<CategoryRandomScreen> createState() => _CategoryRandomScreenState();
}

class _CategoryRandomScreenState extends State<CategoryRandomScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<String> _categories = [];
  double _currentAngle = 0;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _determineSelectedCategory();
            }
          });
    _loadCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/data/categories.json');
    final jsonData = json.decode(data) as Map<String, dynamic>;
    final items = jsonData['categories'] as List<dynamic>;
    setState(() {
      _categories
        ..clear()
        ..addAll(items.map((e) => e.toString()));
    });
  }

  void _spinWheel() {
    if (_categories.isEmpty) return;
    final random = Random();
    final spins = 3 + random.nextInt(3); // 3 to 5 full spins
    final randomAngle = random.nextDouble() * 2 * pi;
    final targetAngle = _currentAngle + spins * 2 * pi + randomAngle;

    _animation = Tween<double>(begin: _currentAngle, end: targetAngle)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0);
    _currentAngle = targetAngle;
  }

  void _determineSelectedCategory() {
    final normalized = _currentAngle % (2 * pi);
    final sectorAngle = 2 * pi / _categories.length;
    final index = (((2 * pi - normalized) % (2 * pi)) ~/ sectorAngle) %
        _categories.length;
    setState(() {
      _selectedCategory = _categories[index];
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PreguntasScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categoría al azar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _spinWheel,
              child: SizedBox(
                width: 250,
                height: 250,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    painter:
                        _WheelPainter(categories: _categories),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedCategory != null)
              Text(
                'Categoría: $_selectedCategory',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            const Text('Toca la ruleta para girar')
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.categories});

  final List<String> categories;
  final List<Color> _colors = const [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final sweep = 2 * pi / max(categories.length, 1);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < categories.length; i++) {
      paint.color = _colors[i % _colors.length];
      final startAngle = -pi / 2 + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: categories[i],
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius);

      final angle = startAngle + sweep / 2;
      final offset = Offset(
        center.dx + (radius / 2) * cos(angle) - textPainter.width / 2,
        center.dy + (radius / 2) * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }

    // draw arrow
    final arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, 20),
      arrowPaint,
    );
    canvas.drawPolygon([
      Offset(center.dx - 10, 20),
      Offset(center.dx + 10, 20),
      Offset(center.dx, 35)
    ], arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on Canvas {
  void drawPolygon(List<Offset> points, Paint paint) {
    final path = Path()..addPolygon(points, true);
    drawPath(path, paint);
  }
}
