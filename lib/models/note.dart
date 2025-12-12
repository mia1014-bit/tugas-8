// lib/models/note.dart

class Note {
  String title;
  String content;
  DateTime createdAt;
  String category; // Kuliah, Organisasi, Pribadi, Lain-lain

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
    required this.category,
  });

  // Konversi Note ke Map untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  // Konversi Map ke Note untuk dibaca
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      category: map['category'] ?? 'Lain-lain',
    );
  }
}