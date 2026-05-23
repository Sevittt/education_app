import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';

class FaqModel extends FaqEntity {
  const FaqModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.category,
    super.systemId,
    super.shortAnswer,
    super.difficulty = "o'rta",
    super.isActive = true,
    super.relatedArticles,
    super.relatedVideos,
    super.viewCount,
    super.helpfulCount,
    super.order,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FaqModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Firestore da category Uzbekcha displayName sifatida saqlanadi
    // Masalan: "Parol Muammolari", "Kirish Muammolari", "Ruxsat" va h.k.
    // Shuning uchun e.name emas, e.displayName bilan solishtirish kerak.
    FaqCategory parseCategory(String? raw) {
      if (raw == null) return FaqCategory.general;
      // displayName bo'yicha qidirish
      try {
        return FaqCategory.values.firstWhere(
          (e) => e.displayName.toLowerCase() == raw.toLowerCase(),
        );
      } catch (_) {}
      // enum.name bo'yicha fallback (inglizcha: 'login', 'password' h.k.)
      try {
        return FaqCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toLowerCase(),
        );
      } catch (_) {}
      return FaqCategory.general;
    }

    return FaqModel(
      id: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      category: parseCategory(data['category'] as String?),
      systemId: data['systemId'] as String?,
      shortAnswer: data['shortAnswer'] as String?,
      difficulty: data['difficulty'] as String? ?? "o'rta",
      isActive: data['isActive'] as bool? ?? true,
      relatedArticles: List<String>.from(data['relatedArticles'] ?? []),
      relatedVideos: List<String>.from(data['relatedVideos'] ?? []),
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      helpfulCount: (data['helpfulCount'] as num?)?.toInt() ?? 0,
      order: (data['order'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'answer': answer,
      // Firestore da Uzbekcha displayName sifatida saqlash (e.g. "Parol Muammolari")
      'category': category.displayName,
      'systemId': systemId,
      'shortAnswer': shortAnswer,
      'difficulty': difficulty,
      'isActive': isActive,
      'relatedArticles': relatedArticles,
      'relatedVideos': relatedVideos,
      'viewCount': viewCount,
      'helpfulCount': helpfulCount,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }


  FaqModel copyWith({
    String? id,
    String? question,
    String? answer,
    FaqCategory? category,
    String? systemId,
    String? shortAnswer,
    String? difficulty,
    bool? isActive,
    List<String>? relatedArticles,
    List<String>? relatedVideos,
    int? viewCount,
    int? helpfulCount,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      systemId: systemId ?? this.systemId,
      shortAnswer: shortAnswer ?? this.shortAnswer,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      relatedArticles: relatedArticles ?? this.relatedArticles,
      relatedVideos: relatedVideos ?? this.relatedVideos,
      viewCount: viewCount ?? this.viewCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
