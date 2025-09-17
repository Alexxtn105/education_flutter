class Questionnaire {
  final String name;
  final List<Question> questions;

  Questionnaire({required this.name, required this.questions});

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<Question> questions = questionsList.map((i) => Question.fromJson(i)).toList();

    return Questionnaire(
      name: json['name'],
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final String text;
  final List<Answer> answers;

  Question({required this.text, required this.answers});

  factory Question.fromJson(Map<String, dynamic> json) {
    var answersList = json['answers'] as List;
    List<Answer> answers = answersList.map((i) => Answer.fromJson(i)).toList();

    return Question(
      text: json['text'],
      answers: answers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class Answer {
  final String text;
  final bool isCorrect;

  Answer({required this.text, required this.isCorrect});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      text: json['text'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}