// lib/models/knowledge_article.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Article kategoriyalari enum
/// Enum ishlatish - hardcoded string'lardan ko'ra xavfsizroq!
enum ArticleCategory {
  beginner,   // Yangi xodimlar uchun
  akt,        // AKT mutaxassislari uchun
  system,     // Tizimga oid
  auth,       // Login/Kirish
  general,    // Umumiy
}

/// Extension - enum'ni string'ga va qaytarib o'girish uchun
extension ArticleCategoryExtension on ArticleCategory {
  String get displayName {
    switch (this) {
      case ArticleCategory.beginner:
        return "Yangi Xodimlar";
      case ArticleCategory.akt:
        return "AKT Mutaxassislari";
      case ArticleCategory.system:
        return "Tizimlar";
      case ArticleCategory.auth:
        return "Kirish/Login";
      case ArticleCategory.general:
        return "Umumiy";
    }
  }
}

/// Knowledge Base maqolalari uchun model
/// 
/// Bu class bir maqolaning barcha ma'lumotlarini saqlaydi.
/// Immutable pattern - barcha fieldlar final, yangi object yaratish orqali yangilanadi
class KnowledgeArticle {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? pdfUrl;              // Nullable - har doim PDF bo'lmasligi mumkin
  final ArticleCategory category;
  final String? systemId;            // Nullable - tizimga bog'liq bo'lmasligi mumkin
  final List<String> tags;           // Search uchun muhim!
  final String authorId;
  final String authorName;
  final int views;                   // Ko'rilganlar soni
  final int helpful;                 // "Foydali" deb belgilaganlar
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool isPinned;               // Muhim maqolalar yuqorida

  /// Constructor - required va optional parametrlar
  KnowledgeArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.pdfUrl,
    required this.category,
    this.systemId,
    required this.tags,
    required this.authorId,
    required this.authorName,
    this.views = 0,               // Default qiymat
    this.helpful = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  /// Firestore DocumentSnapshot'dan object yaratish
  /// 
  /// Bu factory constructor Firestore'dan data kelganda ishlatiladi.
  /// Null safety: har bir field uchun default qiymat beramiz
  factory KnowledgeArticle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return KnowledgeArticle(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      pdfUrl: data['pdfUrl'],
      // Enum parsing - agar noto'g'ri qiymat kelsa, general ishlatiladi
      category: ArticleCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ArticleCategory.general,
      ),
      systemId: data['systemId'],
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      helpful: (data['helpful'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      isPinned: data['isPinned'] ?? false,
    );
  }

  /// Map'dan object yaratish (fromFirestore'ga o'xshash)
  factory KnowledgeArticle.fromMap(Map<String, dynamic> data, String id) {
    return KnowledgeArticle(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      pdfUrl: data['pdfUrl'],
      category: ArticleCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ArticleCategory.general,
      ),
      systemId: data['systemId'],
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      helpful: (data['helpful'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      isPinned: data['isPinned'] ?? false,
    );
  }

  /// Object'ni Firestore'ga saqlash uchun Map'ga o'girish
  /// 
  /// Bu method Firestore'ga yozishda ishlatiladi
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'pdfUrl': pdfUrl,
      'category': category.name,      // Enum'ni string sifatida saqlaymiz
      'systemId': systemId,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'views': views,
      'helpful': helpful,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isPinned': isPinned,
    };
  }

  /// toMap alias (ba'zi joylarda qulay)
  Map<String, dynamic> toMap() => toFirestore();

  /// Object'ni yangilangan versiyasini yaratish (Immutability pattern)
  /// 
  /// Existing object'ni o'zgartirish o'rniga yangi object yaratamiz
  KnowledgeArticle copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? pdfUrl,
    ArticleCategory? category,
    String? systemId,
    List<String>? tags,
    String? authorId,
    String? authorName,
    int? views,
    int? helpful,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isPinned,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      category: category ?? this.category,
      systemId: systemId ?? this.systemId,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      views: views ?? this.views,
      helpful: helpful ?? this.helpful,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Debug uchun string representation
  @override
  String toString() {
    return 'KnowledgeArticle(id: $id, title: $title, category: ${category.name})';
  }

  /// Equality check (testing uchun foydali)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KnowledgeArticle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
