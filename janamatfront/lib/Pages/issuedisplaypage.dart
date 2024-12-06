import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';


class IssueDisplayPage extends StatefulWidget {
  final String issueId;
  final String date;
  final String location;
  final String title;
  final String imageUrl;
  final String description;
  final int upvote_count;
  final int downvote_count;
  final bool isUpvoted;
  final bool isDownvoted;

  IssueDisplayPage({
    required this.issueId,
    required this.date,
    required this.location,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.upvote_count,
    required this.downvote_count,
    required this.isUpvoted,
    required this.isDownvoted,
  });

  @override
  _IssueDisplayPageState createState() => _IssueDisplayPageState();
}

class _IssueDisplayPageState extends State<IssueDisplayPage> {
  late int upvotes;
  late int downvotes;
  late bool isUpvoted;
  late bool isDownvoted;

  @override
  void initState() {
    super.initState();
    upvotes = widget.upvote_count;
    downvotes = widget.downvote_count;
    isUpvoted = widget.isUpvoted;
    isDownvoted = widget.isDownvoted;
  }

  void toggleUpvote() {
    setState(() {
      if (isUpvoted) {
        upvotes--;
        isUpvoted = false;
      } else {
        upvotes++;
        isUpvoted = true;
        if (isDownvoted) {
          downvotes--;
          isDownvoted = false;
        }
      }
    });

    performUpvoteApiCall(widget.issueId, isUpvoted);
  }

  void toggleDownvote() {
    setState(() {
      if (isDownvoted) {
        downvotes--;
        isDownvoted = false;
      } else {
        downvotes++;
        isDownvoted = true;
        if (isUpvoted) {
          upvotes--;
          isUpvoted = false;
        }
      }
    });

    performDownvoteApiCall(widget.issueId, isDownvoted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.date,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Location: ${widget.location}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              widget.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Image.network(widget.imageUrl),
            SizedBox(height: 16),
            Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.thumb_up,
                color: isUpvoted ? Colors.green : Colors.grey,
              ),
              onPressed: toggleUpvote,
            ),
            Text('$upvotes'),
            IconButton(
              icon: Icon(
                Icons.thumb_down,
                color: isDownvoted ? Colors.red : Colors.grey,
              ),
              onPressed: toggleDownvote,
            ),
            Text('$downvotes'),
          ],
        ),
      ),
    );
  }

Future<void> performUpvoteApiCall(String issueId, bool upvoted) async {
  final url = Uri.parse('http://192.168.1.74:8000/upvote/');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'issue_id': issueId,
        'upvoted': upvoted,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        upvotes = responseData['upvote_count'];
        downvotes = responseData['downvote_count'];
        isUpvoted = responseData['voted'];
        isDownvoted = responseData['downvoted'];
      });
    } else {
      print('Failed to upvote: ${response.body}');
    }
  } catch (e) {
    print('Error during upvote: $e');
  }
}

Future<void> performDownvoteApiCall(String issueId, bool downvoted) async {
  final url = Uri.parse('http://192.168.1.74:8000/downvote/');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'issue_id': issueId,
        'downvoted': downvoted,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        upvotes = responseData['upvote_count'];
        downvotes = responseData['downvote_count'];
        isUpvoted = responseData['voted'];
        isDownvoted = responseData['downvoted'];
      });
    } else {
      print('Failed to downvote: ${response.body}');
    }
  } catch (e) {
    print('Error during downvote: $e');
  }
}
}