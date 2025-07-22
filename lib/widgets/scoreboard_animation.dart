import 'package:flutter/material.dart';

class ScoreboardAnimation extends StatefulWidget {
  final String nickname;
  final int score;
  const ScoreboardAnimation({super.key, required this.nickname, required this.score});

  @override
  State<ScoreboardAnimation> createState() => _ScoreboardAnimationState();
}

class _ScoreboardAnimationState extends State<ScoreboardAnimation>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> _players;
  late AnimationController _trophyController;
  late Animation<double> _trophyAnimation;

  @override
  void initState() {
    super.initState();
    _players = [
      {'name': 'Jugador A', 'score': 0},
      {'name': 'Jugador B', 'score': 0},
      {'name': 'Jugador C', 'score': 0},
      {'name': widget.nickname, 'score': widget.score},
    ];
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _trophyAnimation = CurvedAnimation(
      parent: _trophyController,
      curve: Curves.easeInOut,
    );

    // Show the initial order for 2 seconds, then move the player
    Future.delayed(const Duration(seconds: 2), _moveToThird);
  }

  void _moveToThird() {
    if (!mounted) return;
    setState(() {
      final player = _players.removeLast();
      _players.insert(2, player);
    });
    Future.delayed(const Duration(milliseconds: 1500), _moveToSecond);
  }

  void _moveToSecond() {
    if (!mounted) return;
    setState(() {
      final player = _players.removeAt(2);
      _players.insert(1, player);
    });
    Future.delayed(const Duration(milliseconds: 1500), _moveToFirst);
  }

  void _moveToFirst() {
    if (!mounted) return;
    setState(() {
      final player = _players.removeAt(1);
      _players.insert(0, player);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _trophyController.forward();
    });
  }

  @override
  void dispose() {
    _trophyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Column(
            key: ValueKey(_players.first['name']),
            children: _players.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final highlight = player['name'] == widget.nickname;
              return AnimatedContainer(
                key: ValueKey(player['name']),
                duration: const Duration(milliseconds: 500),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: highlight ? Colors.amber.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Text('#${index + 1}'),
                  title: Text(player['name']),
                  trailing: Text(player['score'].toString()),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        SizeTransition(
          sizeFactor: _trophyAnimation,
          axisAlignment: -1.0,
          child: Column(
            children: const [
              Icon(Icons.emoji_events, size: 60, color: Colors.amber),
              SizedBox(height: 8),
              Text(
                'Felicidades eres el puesto numero 1',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
