// lib/models/faq.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// FAQ kategoriyalari
enum FAQCategory {
  login,      // Kirish muammolari
  password,   // Parol muammolari
  upload,     // Fayl yuklash
  access,     // Ruxsat muammolari
  general,    // Umumiy savollar
  technical,  // Texnik muammolar
}

extension FAQCategoryExtension on FAQCategory {
  String get displayName {
    switch (this) {
      case FAQCategory.login:
        return "Kirish Muammolari";
      case FAQCategory.password:
        return "Parol Muammolari";
      case FAQCategory.upload:
        return "Fayl Yuklash";
      case FAQCategory.access:
        return "Ruxsat";
      case FAQCategory.general:
        return "Umumiy";
      case FAQCategory.technical:
        return "Texnik";
    }
  }
  
  /// Kategoriya ikonkasi
  String get icon {
    switch (this) {
      case FAQCategory.login:
        return "🔐";
      case FAQCategory.password:
        return "🔑";
      case FAQCategory.upload:
        return "📤";
      case FAQCategory.access:
        return "🚫";
      case FAQCategory.general:
        return "❓";
      case FAQCategory.technical:
        return "🔧";
    }
  }
}

/// FAQ (Frequently Asked Questions) model
/// 
/// Eng ko'p so'raladigan savollar va javoblarni saqlaydi
class FAQ {
  final String id;
  final String question;          // Savol
  final String answer;            // Javob (markdown formatlangan bo'lishi mumkin)
  final FAQCategory category;
  final String? systemId;         // Qaysi tizimga tegishli
  final List<String> relatedArticles;  // Bog'liq maqolalar ID
  final List<String> relatedVideos;    // Bog'liq videolar ID
  final int viewCount;            // Ko'rilganlar soni
  final int helpfulCount;         // "Foydali" deb belgilaganlar
  final int order;                // Tartib raqami (muhim FAQ'lar yuqorida)
  final Timestamp createdAt;
  final Timestamp updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.systemId,
    this.relatedArticles = const [],
    this.relatedVideos = const [],
    this.viewCount = 0,
    this.helpfulCount = 0,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQ.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FAQ(
      id: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      category: FAQCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => FAQCategory.general,
      ),
      systemId: data['systemId'],
      relatedArticles: List<String>.from(data['relatedArticles'] ?? []),
      relatedVideos: List<String>.from(data['relatedVideos'] ?? []),
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      helpfulCount: (data['helpfulCount'] as num?)?.toInt() ?? 0,
      order: (data['order'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  factory FAQ.fromMap(Map<String, dynamic> data, String id) {
    return FAQ(
      id: id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      category: FAQCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => FAQCategory.general,
      ),
      systemId: data['systemId'],
      relatedArticles: List<String>.from(data['relatedArticles'] ?? []),
      relatedVideos: List<String>.from(data['relatedVideos'] ?? []),
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      helpfulCount: (data['helpfulCount'] as num?)?.toInt() ?? 0,
      order: (data['order'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'answer': answer,
      'category': category.name,
      'systemId': systemId,
      'relatedArticles': relatedArticles,
      'relatedVideos': relatedVideos,
      'viewCount': viewCount,
      'helpfulCount': helpfulCount,
      'order': order,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toMap() => toFirestore();

  /// Bog'liq kontent bormi?
  bool get hasRelatedContent => 
      relatedArticles.isNotEmpty || relatedVideos.isNotEmpty;

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    FAQCategory? category,
    String? systemId,
    List<String>? relatedArticles,
    List<String>? relatedVideos,
    int? viewCount,
    int? helpfulCount,
    int? order,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      systemId: systemId ?? this.systemId,
      relatedArticles: relatedArticles ?? this.relatedArticles,
      relatedVideos: relatedVideos ?? this.relatedVideos,
      viewCount: viewCount ?? this.viewCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FAQ(id: $id, question: $question, category: ${category.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FAQ && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
