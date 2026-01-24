import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// FAQ kategoriyalari
enum FaqCategory {
  login,      // Kirish muammolari
  password,   // Parol muammolari
  upload,     // Fayl yuklash
  access,     // Ruxsat muammolari
  general,    // Umumiy savollar
  technical,  // Texnik muammolar
}

extension FaqCategoryExtension on FaqCategory {
  String get displayName {
    switch (this) {
      case FaqCategory.login:
        return "Kirish Muammolari";
      case FaqCategory.password:
        return "Parol Muammolari";
      case FaqCategory.upload:
        return "Fayl Yuklash";
      case FaqCategory.access:
        return "Ruxsat";
      case FaqCategory.general:
        return "Umumiy";
      case FaqCategory.technical:
        return "Texnik";
    }
  }
  
  /// Kategoriya ikonkasi
  String get icon {
    switch (this) {
      case FaqCategory.login:
        return "🔐";
      case FaqCategory.password:
        return "🔑";
      case FaqCategory.upload:
        return "📤";
      case FaqCategory.access:
        return "🚫";
      case FaqCategory.general:
        return "❓";
      case FaqCategory.technical:
        return "🔧";
    }
  }
}

class FaqEntity extends Equatable {
  final String id;
  final String question;
  final String answer;
  final FaqCategory category;
  final String? systemId;
  final List<String> relatedArticles;
  final List<String> relatedVideos;
  final int viewCount;
  final int helpfulCount;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FaqEntity({
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

  bool get hasRelatedContent => 
      relatedArticles.isNotEmpty || relatedVideos.isNotEmpty;

  @override
  List<Object?> get props => [
    id, question, answer, category, systemId, 
    relatedArticles, relatedVideos, viewCount, 
    helpfulCount, order, createdAt, updatedAt
  ];
}
