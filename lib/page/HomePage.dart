  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:provider/provider.dart';

  // Import your model and service classes (assuming they're defined elsewhere)
  import 'package:bluechat/model/message.dart';

  // Import your page classes (assuming they're defined elsewhere)
  import 'package:bluechat/page/ChatPage.dart';
  import 'package:bluechat/page/Setting.dart';
  import 'package:bluechat/page/Status.dart';
  import 'package:bluechat/service/auth_service.dart'; // Import AuthService

  class HomePage extends StatefulWidget {
    const HomePage({Key? key}) : super(key: key);

    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
    late TabController _tabController;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final TextEditingController _searchController = TextEditingController();
    bool _isSearchActive = false;
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 3, vsync: this);
      _tabController.addListener(_handleTabSelection);
    }

    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }

    void _handleTabSelection() {
      if (_isSearchActive) {
        setState(() {
          _isSearchActive = false;
          _searchController.clear();
        });
      }
    }

    // Access AuthService using Provider
    void signOut() {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.signOut();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Blue Chat', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                  if (!_isSearchActive) {
                    _searchController.clear();
                  }
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(_isSearchActive ? Icons.close : Icons.search, color: Colors.white),
            ),
            const Padding(padding: EdgeInsets.all(10)),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(child: Text('Chat', style: TextStyle(color: Colors.white))),
              Tab(child: Text('Status', style: TextStyle(color: Colors.white))),
              Tab(child: Text('Settings', style: TextStyle(color: Colors.white))),
            ],
             indicatorColor: Colors.white, 
             
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildUserList(),
            const Status(),
            const Setting(),
          ],
        ),
      );
    }

    Widget _buildUserList() {
      return Column(
        children: [
          if (_isSearchActive)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Cari',
                  labelStyle: TextStyle(color: Colors.blue),
                  hintText: 'Cari Nama...',
                  hintStyle: TextStyle(color: Colors.blue),
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onChanged: _onSearchTextChanged,
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }

  final List<Widget> userListWidgets = snapshot.data!.docs
      .where((doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null && _auth.currentUser!.email != data['email']) {
          final String username = data['username']?.toLowerCase() ?? '';
          final String searchText = _searchController.text.toLowerCase();
          return username.contains(searchText);
        } else {
          return false;
        }
      })
      .map<Widget>((doc) => _buildUserListItem(doc))
      .toList();

  if (userListWidgets.isEmpty) {
    return const Center(child: Text('Nama Tidak Di Temukans'));
  }

  return ListView(
    children: userListWidgets,
  );
              },
            ),
          ),
        ],
      );
    }

    Widget _buildUserListItem(DocumentSnapshot document) {
  Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

  if (data != null && _auth.currentUser!.email != data['email']) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30)

      ),
      
      // Add margin and padding as needed
      margin: const EdgeInsets.all(6.0),
      padding: const EdgeInsets.all(6.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.0,
          backgroundColor: Colors.white,
          child: Text(
            data['username'].toString().substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.blue, fontSize: 16.0),
          ),
        ),
        title: Text(
          data['username'] ?? 'Unknown',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_room')
              .doc(_getChatRoomId(data['uid']))
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final messages = snapshot.data!.docs;
              if (messages.isNotEmpty) {
                final lastMessage = messages.first;
                final messageText = lastMessage['message'];
                final senderId = lastMessage['senderId'];

                return Text(
                  senderId == currentUserId
                      ? 'Me: $messageText'
                      : "${data['username'] ?? ''} : $messageText",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color.fromARGB(255, 217, 217, 217),
                    fontSize: 14.0,
                  ),
                );
              }
            }
            return SizedBox.shrink();
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: data['email'] ?? '',
                receiverUserID: data['uid'],
                receiverUsername: data['username'] ?? '',
              ),
            ),
          );
        },
      ),
    );
  } else {
    return const SizedBox();
  }
}


    String _getChatRoomId(String receiverUserId) {
      List<String> ids = [currentUserId, receiverUserId];
      ids.sort();
      return ids.join("_");
    }

    void _onSearchTextChanged(String searchText) {
      setState(() {});
    }
  }


