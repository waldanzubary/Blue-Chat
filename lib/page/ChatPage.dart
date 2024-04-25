import 'package:bluechat/komponen/FieldText.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverUsername;

  const ChatPage({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUsername,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildUserAvatar(),
            SizedBox(width: 10),
            Text(
                 widget.receiverUsername.length > 10
                 ? '${widget.receiverUsername.substring(0, 10)}...'
                  : widget.receiverUsername,
                   style: TextStyle(color: Colors.white),
             ),
            Spacer(), 
            Icon(Icons.phone)
          ],
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), 
          ),
        ),
        shadowColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Method untuk membuat CircleAvatar
  Widget _buildUserAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Text(
        widget.receiverUsername.substring(0, 1).toUpperCase(),
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chat_room')
          .doc(_getChatRoomId())
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            bool isCurrentUser = data['senderId'] == currentUserId;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isCurrentUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      data['message'],
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getFormattedTimestamp(data['timestamp']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: FieldText(
              controller: _messageController,
              hintText: 'Tulis Sebuah pesan...',
              obscureText: false,
            ),
          ),
          SizedBox(width: 12.0),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(
              Icons.send,
              size: 50,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  String _getChatRoomId() {
    List<String> ids = [currentUserId, widget.receiverUserID];
    ids.sort();
    return ids.join("_");
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    _messageController.clear();

    if (message.isNotEmpty) {
      await _firestore
          .collection('chat_room')
          .doc(_getChatRoomId())
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'message': message,
        'timestamp': Timestamp.now(),
        'receiverMessageUsername': widget.receiverUsername,
      });
    }
  }

  String _getFormattedTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String hour = dateTime.hour.toString();
    String minute = dateTime.minute.toString().padLeft(2, '0'); // Pastikan menit selalu dua digit
    String formattedTime = "$hour:$minute WIB"; // Tambahkan label WIB
    return formattedTime;
  }
}
