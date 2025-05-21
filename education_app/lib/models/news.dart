// lib/models/news.dart

class News {
  // Unique identifier for the news item (optional, but good practice)
  final String id;
  // The title of the news article
  final String title;
  // The source of the news (e.g., a website name or organization)
  final String source;
  // The URL to the full news article
  final String url;
  // Optional: Publication date of the news
  final DateTime? publicationDate;

  // Constructor for the News class
  News({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    this.publicationDate, // Optional parameter
  });

  // Optional: Add fromMap and toMap methods for serialization (useful later)
  factory News.fromMap(String id, Map<String, dynamic> map) {
    return News(
      id: id,
      title: map['title'] as String,
      source: map['source'] as String,
      url: map['url'] as String,
      publicationDate:
          map['publicationDate'] != null
              ? DateTime.parse(map['publicationDate'] as String)
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'source': source,
      'url': url,
      'publicationDate':
          publicationDate
              ?.toIso8601String(), // Store date as string if not null
    };
  }
}
