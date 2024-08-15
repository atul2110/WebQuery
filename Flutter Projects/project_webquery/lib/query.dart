import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'questions_page.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  _QueryPageState createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  String _responseText = '';
  bool _isUrlProcessing = false;
  bool _isQuestionProcessing = false;

  // Function to send the URL to the server for processing
  Future<void> _submitUrl() async {
    final String url = _urlController.text;
    if (url.isEmpty) {
      _showSnackbar('Please enter a URL.');
      return;
    }

    setState(() {
      _isUrlProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.209:8000/create/db'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        _showSnackbar('URL processed successfully.');
      } else {
        _handleError(response);
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUrlProcessing = false;
        });
      }
    }
  }

  // Function to submit the question to the server and get the response
  Future<void> _submitQuestion() async {
    final String question = _questionController.text;
    if (question.isEmpty) {
      _showSnackbar('Please enter a question.');
      return;
    }

    setState(() {
      _isQuestionProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.209:8001/ask/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      );

      if (response.statusCode == 200) {
        final answer = response.body.trim();
        setState(() {
          _responseText = answer;
        });
        await _saveQuestion(question, answer);
      } else {
        _handleError(response);
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isQuestionProcessing = false;
        });
      }
    }
  }

  // Function to save the question and its answer to Firebase
  Future<void> _saveQuestion(String question, String answer) async {
    try {
      await FirebaseFirestore.instance.collection('questions').add({
        'question': question,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _showSnackbar('Failed to save question: $e');
    }
  }

  // Function to handle various error cases
  void _handleError(http.Response response) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      if (errorData.containsKey('message')) {
        _showSnackbar('Error: ${errorData['message']}');
      } else {
        _showSnackbar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // If the response body is not JSON or doesn't have an error message
      _showSnackbar(
          'Unexpected error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  // Function to show a snackbar with a message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Page'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuestionsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isUrlProcessing ? null : _submitUrl,
              child: _isUrlProcessing
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Submit URL'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Enter Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isQuestionProcessing ? null : _submitQuestion,
              child: _isQuestionProcessing
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Submit Question'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Response:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _responseText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
