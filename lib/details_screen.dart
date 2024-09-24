import 'package:flutter/material.dart';

class MovieDetailsScreen extends StatelessWidget {
  final dynamic movie;

  MovieDetailsScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['name']),
      ),
      body: Stack(
        children: [
          // Backdrop image for visual enhancement
          movie['image'] != null
              ? Positioned.fill(
                  child: Image.network(
                    movie['image']['original'],
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),  // Add a slight dark overlay
                    colorBlendMode: BlendMode.darken,
                  ),
                )
              : Container(color: Colors.grey[200]),

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster with rounded corners
                  Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: movie['image'] != null
                          ? Image.network(
                              movie['image']['original'],
                              height: 300,
                              width: 200,
                              fit: BoxFit.cover,
                            )
                          : Placeholder(fallbackHeight: 300, fallbackWidth: 200),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Movie name
                  Text(
                    movie['name'],
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Movie rating (if available)
                  if (movie['rating']['average'] != null)
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 24),
                        SizedBox(width: 4),
                        Text(
                          movie['rating']['average'].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 16),

                  // Movie genres (if available)
                  if (movie['genres'] != null && movie['genres'].isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      children: movie['genres'].map<Widget>((genre) {
                        return Chip(
                          label: Text(
                            genre,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blueAccent,
                        );
                      }).toList(),
                    ),

                  SizedBox(height: 16),

                  // Movie summary
                  Text(
                    movie['summary'] != null
                        ? movie['summary'].replaceAll(RegExp(r'<[^>]*>'), '')
                        : 'No summary available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
