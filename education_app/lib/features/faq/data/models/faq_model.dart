import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/faq/domain/entities/faq_entity.dart';

class FaqModel extends FaqEntity {
  const FaqModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.category,
    super.systemId,
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
    
    return FaqModel(
      id: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      category: FaqCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => FaqCategory.general,
      ),
      systemId: data['systemId'],
      relatedArticles: List<String>.from(data['relatedArticles'] ?? []),
      relatedVideos: List<String>.from(data['relatedVideos'] ?? []),
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      helpfulCount: (data['helpfulCount'] as num?)?.toInt() ?? 0,
      order: (data['order'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
