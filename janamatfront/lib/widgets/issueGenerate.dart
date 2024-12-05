import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:janamatfront/Geolocator/geolocation.dart';
import 'package:permission_handler/permission_handler.dart';


class IssueGenerate extends StatefulWidget {
  @override
  _IssueGenerateState createState() => _IssueGenerateState();
}

class _IssueGenerateState extends State<IssueGenerate> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _location;
  List<String> _tags = [];
  File? _image;
   Map<String, String> _locationDetails = {}; // Store location details
  DateTime _selectedDate = DateTime.now();
  String _selectedIssue = 'General'; // Default issue type
  final List<String> issueLabels = [
    'General',
    'Health',
    'Education',
    'Infrastructure',
    // Add more issue types as needed
  ];
  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }
Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    fetchAndDisplayLocation();
  }

  void fetchAndDisplayLocation() async {
    GeoService geoService = GeoService();
    Map<String, String> locationDetails = await geoService.getLocationDetails();

    if (locationDetails.containsKey('error')) {
      print('Error: ${locationDetails['error']}');
    } else {
      setState(() {
        _locationDetails = locationDetails;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image from gallery: $e");
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image from camera: $e");
    }
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitIssue() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Title and Description are required.")),
      );
      return;
    }

    final provider = Provider.of<VotingProvider>(context, listen: false);

    await provider.createIssue(
      title: _titleController.text,
      description: _descriptionController.text,
      tags: _tags,
      location: _location,
      image: _image,
    );

    Navigator.pop(context); // Close the page after submission
  }
   @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String locationText = _locationDetails.isNotEmpty
        ? "${_locationDetails['street'] ?? ''}, ${_locationDetails['city'] ?? ''}, ${_locationDetails['province'] ?? ''}, ${_locationDetails['country'] ?? ''}"
        : "Fetching location...";

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Issue"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
          children: <Widget>[
            ListTile(
              title: Text("Date: $formattedDate"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text("Location: $locationText"),
              trailing: Icon(Icons.location_on),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Issue Type: '),
                DropdownButton<String>(
                  value: _selectedIssue,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedIssue = newValue!;
                    });
                  },
                  items: issueLabels.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Image'),
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: _image == null
                    ? Center(child: Icon(Icons.add, size: 50, color: Colors.grey))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitIssue,
                child: Text('Generate Issue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
