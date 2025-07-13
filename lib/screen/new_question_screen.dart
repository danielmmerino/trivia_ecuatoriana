import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/question_service.dart';

class NewQuestionScreen extends StatefulWidget {
  const NewQuestionScreen({super.key});

  @override
  State<NewQuestionScreen> createState() => _NewQuestionScreenState();
}

class _NewQuestionScreenState extends State<NewQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  Future<List<Category>>? _futureCategories;
  int? _selectedCategory;
  int _selectedDifficulty = 1;
  int _correctOption = 0;

  @override
  void initState() {
    super.initState();
    _futureCategories = CategoryService().fetchCategories();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una categoría')),
      );
      return;
    }
    final options = List.generate(4, (index) {
      return {
        'opcion': _optionControllers[index].text,
        'esCorrecta': (index == _correctOption).toString(),
      };
    });
    final body = {
      'pregunta': _questionController.text,
      'id_categoria': _selectedCategory,
      'id_dificultad': _selectedDifficulty,
      'opciones': options,
    };
    try {
      await QuestionService().createQuestion(body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pregunta creada correctamente')),
      );
      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la pregunta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Pregunta')),
      body: FutureBuilder<List<Category>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(labelText: 'Pregunta'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese la pregunta' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categories
                        .map((c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.nombre),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator: (v) =>
                        v == null ? 'Seleccione una categoría' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(labelText: 'Dificultad'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Fácil')),
                      DropdownMenuItem(value: 2, child: Text('Media')),
                      DropdownMenuItem(value: 3, child: Text('Difícil')),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedDifficulty = v ?? 1),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                  labelText: 'Opción ${index + 1}'),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Ingrese la opción'
                                  : null,
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: _correctOption,
                            onChanged: (v) =>
                                setState(() => _correctOption = v ?? 0),
                          ),
                          const Text('Correcta'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
