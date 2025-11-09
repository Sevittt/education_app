// import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
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

  int? _correctAnswerIndex;
  String? _trueFalseCorrectAnswer;

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
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if ((_selectedQuestionType == QuestionType.multipleChoice &&
              _correctAnswerIndex == null) ||
          (_selectedQuestionType == QuestionType.trueFalse &&
              _trueFalseCorrectAnswer == null)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectCorrectAnswer)));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      String correctAnswer;
      if (_selectedQuestionType == QuestionType.multipleChoice) {
        correctAnswer = _optionControllers[_correctAnswerIndex!].text;
      } else {
        correctAnswer = _trueFalseCorrectAnswer!;
      }

      final newQuestion = Question(
        id: const Uuid().v4(),
        questionText: _questionController.text,
        questionType: _selectedQuestionType,
        options:
            _selectedQuestionType == QuestionType.multipleChoice
                ? _optionControllers.map((c) => c.text).toList()
                : ['True', 'False'],
        correctAnswer: correctAnswer,
      );

      try {
        final quizService = Provider.of<QuizService>(context, listen: false);
        await quizService.addQuestionToQuiz(widget.quizId, newQuestion);

        _formKey.currentState!.reset();
        _questionController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        setState(() {
          _correctAnswerIndex = null;
          _trueFalseCorrectAnswer = null;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.questionAddedSuccessfully)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToAddQuestion}: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addQuestions),
        actions: [
          TextButton(
            onPressed:
                () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(
              l10n.finish,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildQuestionForm(l10n),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(child: _buildQuestionsList(l10n)),
        ],
      ),
    );
  }

  Widget _buildQuestionForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: InputDecoration(labelText: l10n.questionText),
              validator: (v) => v!.isEmpty ? l10n.pleaseEnterAQuestion : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<QuestionType>(
              initialValue: _selectedQuestionType,
              items:
                  QuestionType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == QuestionType.multipleChoice
                                ? l10n.multipleChoice
                                : l10n.trueFalse,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (type) {
                setState(() {
                  _selectedQuestionType = type!;
                  _correctAnswerIndex = null;
                  _trueFalseCorrectAnswer = null;
                });
              },
              decoration: InputDecoration(labelText: l10n.questionType),
            ),
            const SizedBox(height: 16),
            if (_selectedQuestionType == QuestionType.multipleChoice)
              ..._buildMultipleChoiceOptions(l10n),
            if (_selectedQuestionType == QuestionType.trueFalse)
              ..._buildTrueFalseOptions(),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _addQuestion,
                  child: Text(l10n.addQuestion),
                ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions(AppLocalizations l10n) {
    return List.generate(4, (index) {
      return Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: _correctAnswerIndex,
            onChanged: (value) {
              setState(() {
                _correctAnswerIndex = value;
              });
            },
          ),
          Expanded(
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(
                labelText: l10n.option('${index + 1}'),
              ),
              validator: (v) => v!.isEmpty ? l10n.pleaseEnterAnOption : null,
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buildTrueFalseOptions() {
    return [
      RadioListTile<String>(
        title: const Text('True'),
        value: 'True',
        groupValue: _trueFalseCorrectAnswer,
        onChanged: (value) => setState(() => _trueFalseCorrectAnswer = value),
      ),
      RadioListTile<String>(
        title: const Text('False'),
        value: 'False',
        groupValue: _trueFalseCorrectAnswer,
        onChanged: (value) => setState(() => _trueFalseCorrectAnswer = value),
      ),
    ];
  }

  Widget _buildQuestionsList(AppLocalizations l10n) {
    final quizService = Provider.of<QuizService>(context, listen: false);
    return StreamBuilder<List<Question>>(
      stream: quizService.getQuestionsForQuiz(widget.quizId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(l10n.noQuestionsAddedYet));
        }
        final questions = snapshot.data!;
        return ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(question.questionText),
              subtitle: Text(
                "${l10n.correctAnswer}: ${question.correctAnswer}",
              ),
            );
          },
        );
      },
    );
  }
}
