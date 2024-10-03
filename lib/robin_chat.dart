import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // Stores messages: user and bot responses
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();

    if (input.isEmpty) return;

    // Add the user's message to the chat
    setState(() {
      _messages.add({'sender': 'user', 'text': input});
      _controller.clear();
      _isLoading = true;
    });

    try {
      // Send user input to the backend to get movie recommendations
      final response = await http.post(
        Uri.parse('http://192.168.1.133:5000/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'preferences': input}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': data['recommendations'] ?? 'No recommendations found.'
          });
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': 'Failed to get recommendations. Try again.'
          });
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'An error occurred. Please check your connection and try again.'
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    bool isUser = message['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.redAccent : Colors.grey[850], // Dark grey for bot messages
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(2, 2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.white : Colors.white70, // White for bot text
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Recommendation'),
        backgroundColor: Colors.black, // Dark app bar
      ),
      body: Container(
        color: Colors.black, // Black background
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Newest messages appear at the bottom
                padding: EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type Your Prefs.......',
                        // labelText: 'Type your preferences...',
                        hintStyle: TextStyle(color: Colors.white), // White label
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800], // Dark grey fill
                      ),
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
