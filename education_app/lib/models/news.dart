// lib/models/news.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore Timestamp

class News {
  final String id; // Firestore document ID
  final String title;
  final String source;
  final String url;
  final Timestamp? publicationDate; // Use Firestore Timestamp for dates
  final String? imageUrl; // Optional: for displaying an image with the news

  News({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    this.publicationDate,
    this.imageUrl,
  });

  // Factory constructor to create a News object from a Firestore document
  factory News.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return News(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      source: data['source'] ?? 'Unknown Source',
      url: data['url'] ?? '',
      publicationDate: data['publicationDate'] as Timestamp?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  // Method to convert News object to a Map for Firestore
  // Note: 'id' is usually the document ID and not stored as a field within the document itself
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'source': source,
      'url': url,
      'publicationDate': publicationDate, // Store as Timestamp
      'imageUrl': imageUrl,
    };
  }
}
