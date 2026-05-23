// lib/features/library/domain/entities/resource_entity.dart
import 'package:equatable/equatable.dart';

enum ResourceType { eSud, adolat, jibSud, edoSud, other }

class ResourceEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String author;
  final String authorId;
  final ResourceType type;
  final String? url;
  final DateTime createdAt;

  const ResourceEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorId,
    required this.type,
    this.url,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        author,
        authorId,
        type,
        url,
        createdAt,
      ];
}
