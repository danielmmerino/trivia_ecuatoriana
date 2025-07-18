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

  Future<void> _openQuestion(Category category) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreguntasScreen(
          categoryId: category.id,
          category: category,
        ),
      ),
    );
    if (result == true) {
      setState(() => _correctAnswers++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder<List<Category>>(
          future: _futureCategories,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final categories = snapshot.data!;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aciertos: $_correctAnswers',
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        return CategoryItem(
                          iconUrl: c.icono,
                          label: c.nombre,
                          onTap: () => _openQuestion(c),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      if (categories.isNotEmpty) {
                        _openQuestion(categories.first);
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Comenzar trivia'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NewQuestionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Crear preguntas'),
                  ),
                ],
              ),
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
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage('assets/$iconUrl'),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
