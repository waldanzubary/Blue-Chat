import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bluechat/service/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Image Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Setting(),
    );
  }
}

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late User? user;
  File? _image;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null && user != null) {
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(user!.uid + '.jpg');
      try {
        final TaskSnapshot uploadTask = await storageRef.putFile(_image!);
        final String imageUrl = await uploadTask.ref.getDownloadURL();
        await user!.updatePhotoURL(imageUrl);
        setState(() {
          // Update UI jika diperlukan
        });
      } catch (error) {
        print("Error uploading image: $error");
        // Handle error here
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 64,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Text(
                          user != null ? user!.displayName!.substring(0, 1).toUpperCase() : '',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Simpan Gambar'),
              ),
              SizedBox(height: 50),
              _buildInfoCard(
                icon: Icons.email,
                text: user != null ? user!.email ?? 'Email...' : 'Email...',
              ),
              SizedBox(height: 20),
              _buildInfoCard(
                icon: Icons.person,
                text: user != null ? user!.displayName ?? 'Username...' : 'Username...',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Keluar',
                          style: TextStyle(color: Colors.blue),
                        ),
                        content: Text(
                          'Yakin Ingin keluar?',
                          style: TextStyle(color: Colors.blue),
                        ),
                        backgroundColor: Colors.white,
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Batalkan',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final authService = Provider.of<AuthService>(context, listen: false);
                              authService.signOut();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Keluar',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
                child: Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
