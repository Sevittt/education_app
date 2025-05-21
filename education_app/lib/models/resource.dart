// lib/models/resource.dart

// Define an enum for different resource types for clarity and type safety
enum ResourceType { article, video, code, lessonPlan, tutorial, other }

class Resource {
  // Unique identifier for the resource
  final String id;
  // The title of the resource
  final String title;
  // A brief description of the resource
  final String description;
  // The author or creator of the resource
  final String author;
  // The type of resource (using the enum we defined)
  final ResourceType type;
  // Optional URL for online resources
  final String? url;
  // The date and time the resource was created or added
  final DateTime createdAt;

  // Constructor for the Resource class
  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.type,
    this.url, // Optional parameter
    required this.createdAt,
  });

  // Optional: Add a factory constructor for creating a Resource from a Map
  // This will be useful later if we load data from a database or JSON
  factory Resource.fromMap(String id, Map<String, dynamic> map) {
    return Resource(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      type: ResourceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ), // Convert string back to enum
      url: map['url'] as String?,
      createdAt: DateTime.parse(
        map['createdAt'] as String,
      ), // Assuming date is stored as a string
    );
  }

  // Optional: Add a method for converting a Resource to a Map
  // Useful for saving data to a database or converting to JSON
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'type': type.toString().split('.').last, // Store enum as a string
      'url': url,
      'createdAt': createdAt.toIso8601String(), // Store date as a string
    };
  }
}
