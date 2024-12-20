import 'package:flutter/material.dart';
import 'package:janamatfront/issuesimg/issueimg.dart';
import 'package:janamatfront/widgets/issuetype.dart';
import 'package:janamatfront/Pages/Leaderboard.dart'; // Import the Leaderboard page
import 'package:janamatfront/widgets/issueGenerate.dart'; // Import the IssueGenerate page
import 'package:janamatfront/Pages/profile.dart'; // Import the ProfilePage
import 'package:janamatfront/Pages/homepage.dart'; // Import the HomePageContent
import 'package:janamatfront/Pages/notification.dart'; // Import the NotificationPage
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/authenticationProvider.dart'; // Import AuthenticationProvider
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Add this line

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add this line
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      await Provider.of<VotingProvider>(context, listen: false).uploadProfilePicture(File(_imageFile!.path));
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Photo Library'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) async {
    if (index == 1) { // If Leaderboard tab is selected
      await Provider.of<VotingProvider>(context, listen: false).fetchLeaderboard();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      key: _scaffoldKey, // Add this line
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Update this line
          },
          icon: Icon(Icons.person_4, color: Colors.white),
        ),
        title: Text(
          'Janamat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0E2544),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            icon: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("Id: Citizenship Number"),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  _showImageSourceActionSheet(context);
                },
                child: CircleAvatar(
                  backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                  child: _imageFile == null ? Icon(Icons.person, size: 50) : null, // Default icon
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF0E2544),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                authProvider.signOut(); // Sign out the user
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _selectedIndex == 0
            ? SingleChildScrollView(child: HomePageContent())
            : Leaderboard(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Floating action button pressed");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IssueGenerate()),
          ).then((_) {
            print("Returned from IssueGenerate page");
          });
        },
        tooltip: 'Generate Issue',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.leaderboard),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}
