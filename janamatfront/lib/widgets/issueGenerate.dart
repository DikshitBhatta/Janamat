import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';

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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Issue"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 4,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Location"),
                onChanged: (value) {
                  _location = value;
                },
              ),
              SizedBox(height: 10),
              Wrap(
                children: [
                  ..._tags.map((tag) => Chip(label: Text(tag))),
                  ActionChip(
                    label: Text("Add Tag"),
                    onPressed: () {
                      // Add tag functionality (e.g., open dialog to enter tag)
                      setState(() {
                        _tags.add("New Tag");
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitIssue,
                child: Text("Submit Issue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
