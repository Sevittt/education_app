import 'package:equatable/equatable.dart';

class NewsEntity extends Equatable {
  final String id;
  final String title;
  final String source;
  final String url;
  final DateTime? publicationDate;
  final String? imageUrl;

  const NewsEntity({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    this.publicationDate,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, source, url, publicationDate, imageUrl];
}
