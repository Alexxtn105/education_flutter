class TestResult {
  final int id;
  final String sessionId;
  final String userName;
  final String department;
  final String questionnaire;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final DateTime completedAt;
  final double durationSeconds;

  TestResult({
    required this.id,
    required this.sessionId,
    required this.userName,
    required this.department,
    required this.questionnaire,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.completedAt,
    required this.durationSeconds,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      sessionId: json['session_id'],
      userName: json['user_name'],
      department: json['department'],
      questionnaire: json['questionnaire'],
      correctAnswers: json['correct_answers'],
      wrongAnswers: json['wrong_answers'],
      totalQuestions: json['total_questions'],
      scorePercentage: json['score_percentage'].toDouble(),
      completedAt: DateTime.parse(json['completed_at']),
      durationSeconds: json['duration_seconds'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_name': userName,
      'department': department,
      'questionnaire': questionnaire,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'total_questions': totalQuestions,
      'score_percentage': scorePercentage,
      'completed_at': completedAt.toIso8601String(),
      'duration_seconds': durationSeconds,
    };
  }

  String get formattedDate {
    return '${completedAt.day}.${completedAt.month}.${completedAt.year} ${completedAt.hour}:${completedAt.minute.toString().padLeft(2, '0')}';
  }

  String get scoreText {
    return '${correctAnswers}/$totalQuestions (${scorePercentage.toStringAsFixed(1)}%)';
  }

  String get durationText {
    if (durationSeconds < 60) {
      return '${durationSeconds.toStringAsFixed(0)} сек';
    } else {
      return '${(durationSeconds / 60).toStringAsFixed(1)} мин';
    }
  }
}