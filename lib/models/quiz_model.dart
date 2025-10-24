import 'question_model.dart';

class QuizModel {
  String id;
  String title;
  String category;
  String createdBy;
  List<QuestionModel> questions;

  QuizModel({
    this.id = '',
    required this.title,
    required this.category,
    required this.createdBy,
    required this.questions,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'createdBy': createdBy,
    'questions': questions.map((q) => q.toMap()).toList(),
  };

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      createdBy: map['createdBy'] ?? '',
      questions: (map['questions'] as List<dynamic>? ?? [])
          .map((e) => QuestionModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
