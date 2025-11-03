import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save chat message
  Future<void> saveMessage({
    required String text,
    required bool isUser,
  }) async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      await _firestore.collection('chat_history').add({
        'userId': _auth.currentUser!.uid,
        'text': text,
        'isUser': isUser,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save message: ${e.toString()}');
    }
  }

  // Get chat history
  Stream<List<Map<String, dynamic>>> getChatHistory({int limit = 50}) {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('chat_history')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'];
        return {
          'id': doc.id,
          ...data,
          'timestamp': timestamp is Timestamp 
              ? timestamp.toDate() 
              : (timestamp is DateTime ? timestamp : DateTime.now()),
        };
      }).toList().reversed.toList(); // Reverse to show oldest first
    });
  }

  // Clear chat history
  Future<void> clearChatHistory() async {
    try {
      if (_auth.currentUser == null) throw Exception('No user logged in');

      QuerySnapshot snapshot = await _firestore
          .collection('chat_history')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear chat history: ${e.toString()}');
    }
  }
}

