// lib/models/resource.dart

// Remove this import as it would create a circular dependency
// import 'package:education_app/screens/resource/create_resource_screen.dart';

// Define the ResourceType enum
enum ResourceType { article, video, code, lessonPlan, tutorial, other }

class Resource {
  final String id;
  final String title;
  final String description;
  final String author;
  final String authorId;
  final ResourceType type;
  final String? url;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorId,
    required this.type,
    this.url,
    required this.createdAt,
  });

  factory Resource.fromMap(String id, Map<String, dynamic> map) {
    // Helper function for safe string extraction
    String getString(String key, String defaultValue) {
      var value = map[key];
      if (value == null) {
        print(
          "Warning: Field '$key' is null for resource ID $id. Using default: '$defaultValue'",
        );
        return defaultValue;
      }
      if (value is String) {
        return value;
      }
      print(
        "Warning: Field '$key' is not a String for resource ID $id. Converting to string.",
      );
      return value.toString();
    }

    // Validate authorId (required field)
    final authorIdValue = map['authorId'] as String?;
    if (authorIdValue == null) {
      throw FormatException(
        "Missing required field 'authorId' for resource ID $id",
      );
    }

    // Handle resource type with fallback
    final typeString = getString('type', 'other');
    ResourceType resourceType;
    try {
      resourceType = ResourceType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            typeString.toLowerCase(),
      );
    } catch (e) {
      print(
        "Warning: Invalid resource type '$typeString' for ID $id. Using 'other'",
      );
      resourceType = ResourceType.other;
    }

    // Handle createdAt with validation
    DateTime createdAtDate;
    try {
      final createdAtString = map['createdAt'] as String?;
      if (createdAtString == null) {
        print(
          "Warning: Missing 'createdAt' for resource ID $id. Using current time.",
        );
        createdAtDate = DateTime.now();
      } else {
        createdAtDate = DateTime.parse(createdAtString);
      }
    } catch (e) {
      print(
        "Warning: Invalid date format for resource ID $id. Using current time.",
      );
      createdAtDate = DateTime.now();
    }

    return Resource(
      id: id,
      title: getString('title', 'Untitled Resource'),
      description: getString('description', 'No description available.'),
      author: getString('author', 'Unknown Author'),
      authorId: authorIdValue,
      type: resourceType,
      url: map['url'] as String?,
      createdAt: createdAtDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'authorId': authorId,
      'type': type.toString().split('.').last,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
