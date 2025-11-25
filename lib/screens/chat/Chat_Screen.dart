import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
// Removed unused import
import 'package:master_mind/utils/const.dart'; // Contains your custom colors like buttonColor
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/shimmer_avatar.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final record = AudioRecorder();
  bool _isRecording = false;

  // Theme customization for sent message bubbles
  Color sentBubbleColor = buttonColor; // default value from const.dart
  Color receivedBubbleColor = Colors.grey[300]!;

  // Toggle for showing/hiding extra features
  bool _showExtras = false;

  @override
  void dispose() {
    _textController.dispose();
    _audioPlayer.dispose();
    record.dispose();
    super.dispose();
  }

  // Send a text message
  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('messages').add({
      'text': text,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'Unknown',
      'senderProfile': user.photoURL ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
      'seen': false,
    });
  }

  // Send an image message
  Future<void> sendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final storageRef = FirebaseStorage.instance
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

  // Send a document message
  Future<void> sendDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      final storageRef = FirebaseStorage.instance.ref().child(
          'chat_documents/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}');
      await storageRef.putFile(file);
      final documentUrl = await storageRef.getDownloadURL();
      await _firestore.collection('messages').add({
        'documentUrl': documentUrl,
        'documentName': result.files.single.name,
        'senderId': _auth.currentUser!.uid,
        'senderName': _auth.currentUser!.displayName ?? 'Unknown',
        'senderProfile': _auth.currentUser!.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'document',
        'seen': false,
      });
    }
  }

  // Send a video message
  Future<void> sendVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final file = File(video.path);
      final storageRef = FirebaseStorage.instance
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

  // Send a location message
  Future<void> sendLocation() async {
    // For demonstration, we use a fixed location.
    // In production, use a package like geolocator to get the current location.
    double latitude = 37.4219983;
    double longitude = -122.084;
    String locationUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    await _firestore.collection('messages').add({
      'location': locationUrl,
      'senderId': _auth.currentUser!.uid,
      'senderName': _auth.currentUser!.displayName ?? 'Unknown',
      'senderProfile': _auth.currentUser!.photoURL ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'location',
      'seen': false,
    });
  }

  // Start voice recording
  Future<void> startRecording() async {
    if (await record.hasPermission()) {
      await record.start(const RecordConfig(),
          path: '${Directory.systemTemp.path}/recording.m4a');
      setState(() {
        _isRecording = true;
      });
    }
  }

  // Stop recording and send the audio message
  Future<void> stopRecording() async {
    final path = await record.stop();
    setState(() {
      _isRecording = false;
    });
    if (path != null) {
      final file = File(path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_audio/${DateTime.now().millisecondsSinceEpoch}.m4a');
      await storageRef.putFile(file);
      final audioUrl = await storageRef.getDownloadURL();
      await _firestore.collection('messages').add({
        'audioUrl': audioUrl,
        'senderId': _auth.currentUser!.uid,
        'senderName': _auth.currentUser!.displayName ?? 'Unknown',
        'senderProfile': _auth.currentUser!.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'audio',
        'seen': false,
      });
    }
  }

  // Play an audio message
  Future<void> _playAudio(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  // React to a message by updating its reaction field
  Future<void> reactToMessage(String messageId, String reaction) async {
    await _firestore.collection('messages').doc(messageId).update({
      'reaction': reaction,
    });
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  // Mark message as seen
  Future<void> markMessageAsSeen(DocumentSnapshot doc) async {
    if (!doc.get('seen')) {
      await _firestore.collection('messages').doc(doc.id).update({
        'seen': true,
      });
    }
  }

  // Show a bottom sheet with reaction and delete options
  void _showReactionOptions(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Text("❤️", style: TextStyle(fontSize: 24)),
              onPressed: () {
                reactToMessage(messageId, "❤️");
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Text("😂", style: TextStyle(fontSize: 24)),
              onPressed: () {
                reactToMessage(messageId, "😂");
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Text("👍", style: TextStyle(fontSize: 24)),
              onPressed: () {
                reactToMessage(messageId, "👍");
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Text("🔥", style: TextStyle(fontSize: 24)),
              onPressed: () {
                reactToMessage(messageId, "🔥");
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                deleteMessage(messageId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Build each message bubble
  Widget _buildMessageWidget(DocumentSnapshot doc) {
    final message = doc.data() as Map<String, dynamic>;
    final bool isMe = message['senderId'] == _auth.currentUser!.uid;

    // Mark incoming messages as seen
    if (!isMe) {
      markMessageAsSeen(doc);
    }

    return GestureDetector(
      onLongPress: () {
        _showReactionOptions(doc.id);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            ShimmerAvatar(
              radius: 20,
              imageUrl: (message['senderProfile'] != null &&
                      message['senderProfile'].isNotEmpty)
                  ? message['senderProfile']
                  : null,
            ),
          SizedBox(width: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe ? sentBubbleColor : receivedBubbleColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display sender name
                    Text(
                      message['senderName'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    // Display message content based on type
                    if (message['type'] == 'text')
                      Text(
                        message['text'],
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black),
                      )
                    else if (message['type'] == 'image')
                      Image.network(message['imageUrl'], width: 200)
                    else if (message['type'] == 'document')
                      Text(
                        '📄 Document: ${message['documentUrl']}',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: isMe ? Colors.white : Colors.black),
                      )
                    else if (message['type'] == 'audio')
                      IconButton(
                        icon: Icon(Icons.play_arrow,
                            color: isMe ? Colors.white : Colors.black),
                        onPressed: () => _playAudio(message['audioUrl']),
                      )
                    else if (message['type'] == 'video')
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                      videoUrl: message['videoUrl'])));
                        },
                        child: Icon(Icons.play_circle_fill,
                            size: 40,
                            color: isMe ? Colors.white : Colors.black),
                      )
                    else if (message['type'] == 'location')
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse(message['location']);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Text("📍 View Location",
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline)),
                      ),
                    if (message.containsKey('reaction'))
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          message['reaction'],
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    if (isMe)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          message['seen'] == true
                              ? Icons.done_all
                              : Icons.check,
                          size: 16,
                          color: message['seen'] == true
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8),
          if (isMe)
            ShimmerAvatar(
              radius: 20,
              imageUrl: (message['senderProfile'] != null &&
                      message['senderProfile'].isNotEmpty)
                  ? message['senderProfile']
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Always-visible row: Toggle button and text field with dynamic suffix icon.
          Row(
            children: [
              IconButton(
                icon: Icon(_showExtras ? Icons.attach_file : Icons.attach_file),
                onPressed: () {
                  setState(() {
                    _showExtras = !_showExtras;
                  });
                },
              ),
              // Use Expanded so the TextField takes available width
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _textController,
                        builder: (context, value, child) {
                          if (value.text.isNotEmpty) {
                            return IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                sendMessage(value.text);
                                _textController.clear();
                              },
                            );
                          } else {
                            return IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.sticky_note_2),
                            );
                          }
                        },
                      ),
                      hintText: 'Write your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                onPressed: _isRecording ? stopRecording : startRecording,
              ),
              IconButton(
                icon: Icon(Icons.camera),
                onPressed: () {
                  // Add your camera action here
                },
              ),
            ],
          ),
          // Extra features row: Only visible when _showExtras is true.
          if (_showExtras)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.image), onPressed: sendImage),
                  IconButton(
                      icon: Icon(Icons.edit_document), onPressed: sendDocument),
                  IconButton(icon: Icon(Icons.videocam), onPressed: sendVideo),
                  IconButton(
                      icon: Icon(Icons.location_on), onPressed: sendLocation),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: () {
              setState(() {
                sentBubbleColor =
                    sentBubbleColor == buttonColor ? Colors.green : buttonColor;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _buildMessageWidget(docs[index]);
                  },
                );
              },
            ),
          ),
          Divider(
            thickness: 1,
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
}

// Placeholder for a video player screen.
class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;
  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(child: Text("Video Player for URL: $videoUrl")),
    );
  }
}
