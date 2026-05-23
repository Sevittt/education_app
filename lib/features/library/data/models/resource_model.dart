// lib/features/library/data/models/resource_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/resource_entity.dart';

class ResourceModel extends ResourceEntity {
  const ResourceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.author,
    required super.authorId,
    required super.type,
    super.url,
    required super.createdAt,
  });

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;

    // Helper for safe string extraction
    String getString(String key, String defaultValue) {
      if (data[key] == null) return defaultValue;
      return data[key].toString();
    }

    // Type parsing
    final typeString = getString('type', 'eSud');
    ResourceType resourceType;
    try {
      resourceType = ResourceType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == typeString.toLowerCase(),
      );
    } catch (_) {
      resourceType = ResourceType.eSud;
    }

    // Date parsing
    DateTime createdAtDate;
    try {
      if (data['createdAt'] is Timestamp) {
        createdAtDate = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAtDate = DateTime.parse(data['createdAt']);
      } else {
        createdAtDate = DateTime.now();
      }
    } catch (_) {
      createdAtDate = DateTime.now();
    }

    return ResourceModel(
      id: id,
      title: getString('title', 'Untitled Resource'),
      description: getString('description', 'No description'),
      author: getString('author', 'Unknown'),
      authorId: getString('authorId', ''),
      type: resourceType,
      url: data['url'] as String?,
      createdAt: createdAtDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'authorId': authorId,
      'type': type.toString().split('.').last,
      'url': url,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
