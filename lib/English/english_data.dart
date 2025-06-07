class Word {
  final int id;
  final String englishWord;
  final String vietnameseTranslation;
  final String? exampleSentence; // Có thể null nên dùng String?
  final String? category; // Có thể null nên dùng String?

  // Constructor để khởi tạo đối tượng Word
  Word({
    required this.id,
    required this.englishWord,
    required this.vietnameseTranslation,
    this.exampleSentence,
    this.category,
  });

  // Factory constructor để tạo đối tượng Word từ một Map (thường là từ JSON)
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      englishWord: json['english_word'] as String,
      vietnameseTranslation: json['vietnamese_translation'] as String,
      exampleSentence:
          json['example_sentence'] as String?, // Ép kiểu an toàn cho nullable
      category: json['category'] as String?, // Ép kiểu an toàn cho nullable
    );
  }

  // (Tùy chọn) Phương thức để chuyển đối tượng Word thành Map (ví dụ để lưu vào DB hoặc gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english_word': englishWord,
      'vietnamese_translation': vietnameseTranslation,
      'example_sentence': exampleSentence,
      'category': category,
    };
  }

  // (Tùy chọn) Ghi đè toString để dễ dàng debug
  @override
  String toString() {
    return 'Word(id: $id, englishWord: $englishWord, vietnameseTranslation: $vietnameseTranslation, category: $category)';
  }
}
