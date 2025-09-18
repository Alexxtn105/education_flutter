class QuestionValidator {
  static String? validateQuestionCount(String? value, int maxAvailable) {
    if (value == null || value.isEmpty) {
      return 'Введите количество вопросов';
    }

    final count = int.tryParse(value);
    if (count == null) {
      return 'Введите корректное число';
    }

    if (count < 0) {
      return 'Количество не может быть отрицательным';
    }

    if (count > maxAvailable) {
      return 'Не может быть больше $maxAvailable';
    }

    return null;
  }
}