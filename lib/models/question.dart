class Question {
  final String question;
  final List<Option> options;

  Question({required this.question, required this.options});

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List;
    List<Option> options = optionsList.map((i) => Option.fromJson(i)).toList();

    return Question(
      question: json['question'],
      options: options,
    );
  }
}

class Option {
  final String text;
  final bool correct;

  Option({required this.text, required this.correct});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'],
      correct: json['correct'] ?? false,
    );
  }
}