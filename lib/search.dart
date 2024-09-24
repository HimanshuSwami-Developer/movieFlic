import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movieflic/details_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchTerm = "";
  List<dynamic> searchResults = [];

  // Fetch movies based on the search term
  Future<void> fetchMovies(String query) async {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$query'));

    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: "Search here ...",
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) {
                setState(() {
                  searchTerm = value;
                  fetchMovies(searchTerm);
                });
              },
            ),
            SizedBox(height: 16),

            // Display search results in a Netflix-style grid
            Expanded(
              child: searchResults.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        childAspectRatio: 0.7, 
                        mainAxisSpacing: 8, 
                        crossAxisSpacing: 8, 
                      ),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        var movie = searchResults[index]['show'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailsScreen(movie: movie),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4), // Shadow position
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: movie['image'] != null
                                  ? Image.network(
                                      movie['image']['medium'],
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[800],
                                      child: Center(
                                        child: Text(
                                          movie['name'],
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No results found. Start searching!',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black, 
    );
  }
}
