import 'package:cloud_firestore/cloud_firestore.dart';

class SearchIndexModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'article', 'video', 'resource', 'faq', 'system'
  final String text; // The full text/content for vector search
  final String path; // The path/route to navigate when selected
  final DateTime createdAt;

  SearchIndexModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.text,
    required this.path,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'text': text,
      'path': path,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SearchIndexModel.fromMap(Map<String, dynamic> map, String id) {
    return SearchIndexModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      text: map['text'] ?? '',
      path: map['path'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
