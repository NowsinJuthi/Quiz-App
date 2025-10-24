class QuestionModel {
  String id;
  String question;
  List<String> options;
  int correctIndex;

  QuestionModel({
    this.id = '',
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
  };

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }
}
