import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';

class NewsModel extends NewsEntity {
  const NewsModel({
    required super.id,
    required super.title,
    required super.source,
    required super.url,
    super.publicationDate,
    super.imageUrl,
  });

  factory NewsModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NewsModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      source: data['source'] ?? 'Unknown Source',
      url: data['url'] ?? '',
      publicationDate: data['publicationDate'] != null 
          ? (data['publicationDate'] as Timestamp).toDate() 
          : null,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'source': source,
      'url': url,
      'publicationDate': publicationDate != null 
          ? Timestamp.fromDate(publicationDate!) 
          : null,
      'imageUrl': imageUrl,
    };
  }
}
