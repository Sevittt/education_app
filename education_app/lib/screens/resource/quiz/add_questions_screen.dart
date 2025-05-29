// lib/screens/resource/quiz/add_questions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/question.dart';
import '../../../services/quiz_service.dart';

class AddQuestionsScreen extends StatefulWidget {
  final String quizId;
  const AddQuestionsScreen({super.key, required this.quizId});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  QuestionType _selectedQuestionType = QuestionType.multipleChoice;
  String? _correctAnswer;
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (_formKey.currentState!.validate()) {
      if (_correctAnswer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a correct answer.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final newQuestion = Question(
        id: const Uuid().v4(), // Generate a unique ID for the question
        questionText: _questionController.text,
        questionType: _selectedQuestionType,
        options:
            _selectedQuestionType == QuestionType.multipleChoice
                ? _optionControllers.map((c) => c.text).toList()
                : ['True', 'False'],
        correctAnswer: _correctAnswer!,
      );

      try {
        final quizService = Provider.of<QuizService>(context, listen: false);
        await quizService.addQuestionToQuiz(widget.quizId, newQuestion);

        // Clear the form for the next question
        _formKey.currentState!.reset();
        _questionController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        setState(() {
          _correctAnswer = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add question: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Questions'),
        actions: [
          TextButton(
            onPressed:
                () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(
              'FINISH',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Part 1: The form for adding a new question
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildQuestionForm(),
          ),
          const Divider(height: 1),
          // Part 2: The list of already added questions
          Expanded(child: _buildQuestionsList()),
        ],
      ),
    );
  }

  // The form for creating a new question
  Widget _buildQuestionForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question Text'),
              validator: (v) => v!.isEmpty ? 'Please enter a question' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<QuestionType>(
              value: _selectedQuestionType,
              items:
                  QuestionType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == QuestionType.multipleChoice
                                ? 'Multiple Choice'
                                : 'True/False',
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (type) {
                setState(() {
                  _selectedQuestionType = type!;
                  _correctAnswer = null; // Reset correct answer on type change
                });
              },
              decoration: const InputDecoration(labelText: 'Question Type'),
            ),
            const SizedBox(height: 16),
            if (_selectedQuestionType == QuestionType.multipleChoice)
              ..._buildMultipleChoiceOptions(),
            if (_selectedQuestionType == QuestionType.trueFalse)
              ..._buildTrueFalseOptions(),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _addQuestion,
                  child: const Text('Add Question'),
                ),
          ],
        ),
      ),
    );
  }

  // Generates the fields for multiple choice answers
  List<Widget> _buildMultipleChoiceOptions() {
    return List.generate(4, (index) {
      return Row(
        children: [
          Radio<String>(
            value: _optionControllers[index].text,
            groupValue: _correctAnswer,
            onChanged: (value) {
              setState(() {
                _correctAnswer = value;
              });
            },
          ),
          Expanded(
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(labelText: 'Option ${index + 1}'),
              validator: (v) => v!.isEmpty ? 'Please enter an option' : null,
              onChanged: (text) {
                // Update radio value if the text changes
                setState(() {});
              },
            ),
          ),
        ],
      );
    });
  }

  // Generates the fields for true/false answers
  List<Widget> _buildTrueFalseOptions() {
    return [
      RadioListTile<String>(
        title: const Text('True'),
        value: 'True',
        groupValue: _correctAnswer,
        onChanged: (value) => setState(() => _correctAnswer = value),
      ),
      RadioListTile<String>(
        title: const Text('False'),
        value: 'False',
        groupValue: _correctAnswer,
        onChanged: (value) => setState(() => _correctAnswer = value),
      ),
    ];
  }

  // Builds the list of questions already added to this quiz
  Widget _buildQuestionsList() {
    final quizService = Provider.of<QuizService>(context, listen: false);
    return StreamBuilder<List<Question>>(
      stream: quizService.getQuestionsForQuiz(widget.quizId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No questions added yet.'));
        }
        final questions = snapshot.data!;
        return ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(question.questionText),
              subtitle: Text(question.correctAnswer),
            );
          },
        );
      },
    );
  }
}
