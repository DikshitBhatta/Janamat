import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ProfilePage extends StatelessWidget {
  Future<bool> _checkImageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF0E2544),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<bool>(
              future: _checkImageExists("assets/issues/watersupply.jpg"), // Update this line
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/issues/watersupply.jpg"), // Update this line
                    );
                  } else {
                    return CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    );
                  }
                } else {
                  return CircleAvatar(
                    radius: 50,
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'User Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Id: Citizenship Number',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
