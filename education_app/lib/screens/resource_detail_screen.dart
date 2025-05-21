// lib/screens/resource_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/resource.dart'; // Import the Resource model
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for opening URLs

class ResourceDetailScreen extends StatelessWidget {
  // This screen needs to receive a Resource object to display
  final Resource resource;

  const ResourceDetailScreen({super.key, required this.resource});

  // Function to handle launching a URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Handle error (e.g., show a snackbar)
      // In a real app, you might want to show a user-friendly error message
      print('Could not launch $uri'); // Print error to console
      // Example of showing a snackbar (requires a ScaffoldMessenger in the ancestor tree):
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Could not open the link.')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          resource.title,
        ), // Display the resource title in the app bar
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Allows scrolling if the content is long
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to the left
            children: [
              // Display Resource Title (can be styled differently from app bar)
              Text(
                resource.title,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),

              // Display Author and Type
              Text(
                'By ${resource.author} (${resource.type.toString().split('.').last})',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16.0),

              // Display Description
              Text(
                resource.description,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),

              // Display URL if available and make it tappable
              if (resource.url != null) // Only show if URL exists
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Link:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    // --- START OF INTEGRATED CODE ---
                    // Use InkWell to make the text tappable
                    InkWell(
                      onTap: () {
                        // Call the launch function when tapped
                        _launchUrl(
                          resource.url!,
                        ); // Use resource.url! as we checked it's not null
                      },
                      child: Text(
                        resource.url!, // Display the URL text
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.blue, // Make it look like a link
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    // --- END OF INTEGRATED CODE ---
                  ],
                ),

              // Display creation date
              const SizedBox(height: 16.0),
              Text(
                'Added on: ${resource.createdAt.toLocal().toString().split('.')[0]}', // Display creation date
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
