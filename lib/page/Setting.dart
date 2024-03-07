import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluechat/service/auth_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 40, // Sesuaikan dengan lebar layar
              height: 100,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      user != null ? user.email ?? 'Email...' : 'Email...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 40, // Sesuaikan dengan lebar layar
              height: 100,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      user != null ? user.displayName ?? 'Username...' : 'Username...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 200, // Lebar kontainer Pengaturan 2
                  height: 100, // Tinggi kontainer Pengaturan 2
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Pengaturan 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Keluar'),
                      content: Text('Yakin Ingin keluar?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Batalkan'),
                        ),
                        TextButton(
                          onPressed: () {
                            final authService = Provider.of<AuthService>(context, listen: false);
                            authService.signOut();
                            Navigator.of(context).pop(); 
                          },
                          child: Text('Keluar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}
