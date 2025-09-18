class IncorrectAnswer {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final int questionIndex;

  IncorrectAnswer({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.questionIndex,
  });

  factory IncorrectAnswer.fromJson(Map<String, dynamic> json) {
    return IncorrectAnswer(
      question: json['question'],
      userAnswer: json['user_answer'],
      correctAnswer: json['correct_answer'],
      questionIndex: json['question_index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'question_index': questionIndex,
    };
  }
}

class AnswerResponse {
  final bool correct;
  final bool completed;
  final List<IncorrectAnswer> incorrectAnswers;

  AnswerResponse({
    required this.correct,
    required this.completed,
    required this.incorrectAnswers,
  });

  factory AnswerResponse.fromJson(Map<String, dynamic> json) {
    var incorrectList = json['incorrect_answers'] as List?;
    return AnswerResponse(
      correct: json['correct'],
      completed: json['completed'],
      incorrectAnswers: incorrectList != null
          ? incorrectList.map((i) => IncorrectAnswer.fromJson(i)).toList()
          : [],
    );
  }
}