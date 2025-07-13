import 'package:flutter/material.dart';
import 'preguntas_screen.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Category>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = CategoryService().fetchCategories();
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
                      return CategoryItem(iconUrl: c.icono, label: c.nombre);
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PreguntasScreen(),
                      ),
                    );
                  },
                  child: const Text('COMENZAR TRIVIA'),
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

  const CategoryItem({super.key, required this.iconUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(iconUrl),
          backgroundColor: Colors.blueAccent,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        )
      ],
    );
  }
}
