import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:sud_qollanma/features/quiz/domain/entities/quiz.dart';
import 'package:uuid/uuid.dart';
import 'package:sud_qollanma/features/quiz/presentation/screens/add_questions_screen.dart';

class CreateQuizScreen extends StatefulWidget {
  final Quiz? quizToEdit;

  const CreateQuizScreen({super.key, this.quizToEdit});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _resourceIdController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.quizToEdit != null) {
      _titleController.text = widget.quizToEdit!.title;
      _descController.text = widget.quizToEdit!.description;
      _resourceIdController.text = widget.quizToEdit!.resourceId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _resourceIdController.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quiz = Quiz(
        id: widget.quizToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        resourceId: _resourceIdController.text,
        questions: widget.quizToEdit?.questions ?? [],
      );

      if (widget.quizToEdit != null) {
        await context.read<QuizProvider>().updateQuiz(quiz);
      } else {
        await context.read<QuizProvider>().createQuiz(quiz);
      }

      if (mounted) {
        if (widget.quizToEdit == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddQuestionsScreen(quiz: quiz),
            ),
          );
        } else {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.quizToEdit != null
                ? 'Quiz updated successfully'
                : AppLocalizations.of(context)!.quizCreatedSuccessfully),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${AppLocalizations.of(context)!.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizToEdit != null
            ? 'Edit Quiz Details'
            : AppLocalizations.of(context)!.createQuizTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _resourceIdController,
                decoration:
                    const InputDecoration(labelText: 'Resource ID (Optional)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveQuiz,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.quizToEdit != null
                        ? 'Update Details'
                        : AppLocalizations.of(context)!.saveQuizAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
