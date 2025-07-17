import 'package:flutter/material.dart';
import 'preguntas_screen.dart';
import 'new_question_screen.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Category>> _futureCategories;
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _futureCategories = CategoryService().fetchCategories();
  }

  Future<void> _openQuestion(int categoryId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreguntasScreen(categoryId: categoryId),
      ),
    );
    if (result == true) {
      setState(() => _correctAnswers++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFA726), // Fondo naranja
      body: SafeArea(
        child: FutureBuilder<List<Category>>(
          future: _futureCategories,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final categories = snapshot.data!;
            return Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'CATEGORÍAS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aciertos: $_correctAnswers',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      final c = categories[index];
                      return CategoryItem(
                        iconUrl: c.icono,
                        label: c.nombre,
                        onTap: () => _openQuestion(c.id),
                      );
                    },
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (categories.isNotEmpty) {
                      _openQuestion(categories.first.id);
                    }
                  },
                  child: const Text('COMENZAR TRIVIA'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewQuestionScreen(),
                      ),
                    );
                  },
                  child: const Text('CREAR PREGUNTAS'),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String iconUrl;
  final String label;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.iconUrl,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/$iconUrl'),
            backgroundColor: Colors.blueAccent,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          )
        ],
      ),
    );
  }
}
