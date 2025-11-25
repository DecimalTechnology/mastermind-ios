import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Stream<QuerySnapshot> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String text) async {
    await _firestore.collection('messages').add({
      'text': text,
      'senderId': _auth.currentUser!.uid,
      'senderName': _auth.currentUser!.displayName ?? 'Unknown',
      'senderProfile': _auth.currentUser!.photoURL ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
      'seen': false,
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  Future<void> updateMessage(String messageId, String newText) async {
    await _firestore.collection('messages').doc(messageId).update({
      'text': newText,
      'edited': true,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  void markMessageAsSeen(DocumentSnapshot messageDoc) {
    if (messageDoc['senderId'] != _auth.currentUser!.uid &&
        messageDoc['seen'] != true) {
      _firestore
          .collection('messages')
          .doc(messageDoc.id)
          .update({'seen': true});
    }
  }

  Future<void> reactToMessage(String messageId, String reaction) async {
    await _firestore.collection('messages').doc(messageId).update({
      'reaction': reaction,
    });
  }

  Future<void> sendVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef = _storage
          .ref()
          .child('chat_videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
      await storageRef.putFile(file);
      final videoUrl = await storageRef.getDownloadURL();
      await _firestore.collection('messages').add({
        'videoUrl': videoUrl,
        'senderId': _auth.currentUser!.uid,
        'senderName': _auth.currentUser!.displayName ?? 'Unknown',
        'senderProfile': _auth.currentUser!.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'video',
        'seen': false,
      });
    }
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef = _storage
          .ref()
          .child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();
      await _firestore.collection('messages').add({
        'imageUrl': imageUrl,
        'senderId': _auth.currentUser!.uid,
        'senderName': _auth.currentUser!.displayName ?? 'Unknown',
        'senderProfile': _auth.currentUser!.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'image',
        'seen': false,
      });
    }
  }

  Future<void> sendDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      final storageRef = _storage
          .ref()
          .child('chat_documents/${DateTime.now().millisecondsSinceEpoch}.pdf');
      await storageRef.putFile(file);
      final documentUrl = await storageRef.getDownloadURL();
      await _firestore.collection('messages').add({
        'documentUrl': documentUrl,
        'senderId': _auth.currentUser!.uid,
        'senderName': _auth.currentUser!.displayName ?? 'Unknown',
        'senderProfile': _auth.currentUser!.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'document',
        'seen': false,
      });
    }
  }
}
