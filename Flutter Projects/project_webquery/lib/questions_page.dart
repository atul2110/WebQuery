import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({Key? key}) : super(key: key);

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _questionsStream;

  @override
  void initState() {
    super.initState();
    _questionsStream = _firestore
        .collection('questions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previously Asked Questions'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Container(
        color: Colors.grey[900], // Set the background color here
        child: StreamBuilder<QuerySnapshot>(
          stream: _questionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No questions found.'));
            }

            final questions = snapshot.data!.docs;
            return ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final questionData =
                    questions[index].data() as Map<String, dynamic>;
                final questionText =
                    questionData['question'] ?? 'No question text';
                final answerText =
                    questionData['answer'] ?? 'No answer available';

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'), // Numbering starts from 1
                  ),
                  title: Text(questionText,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(answerText,
                      style: const TextStyle(color: Colors.white70)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
