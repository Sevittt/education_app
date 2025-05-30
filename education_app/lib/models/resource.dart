// lib/models/resource.dart

// Remove this import as it would create a circular dependency
// import 'package:education_app/screens/resource/create_resource_screen.dart';

// Define the ResourceType enum
enum ResourceType { 
  article, 
  video, 
  code, 
  lessonPlan, 
  tutorial, 
  other 
}

class Resource {
  final String id;
  final String title;
  final String description;
  final String author; // Keep for display name
  final String authorId; // Add this for UID
  final ResourceType type;
  final String? url;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorId, // Add to constructor
    required this.type,
    this.url,
    required this.createdAt,
  });

  factory Resource.fromMap(String id, Map<String, dynamic> map) {
    return Resource(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      authorId: map['authorId'] as String, // Read from map
      type: ResourceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      url: map['url'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'authorId': authorId, // Save to map
      'type': type.toString().split('.').last,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
