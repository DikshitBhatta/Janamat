import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VotingProvider with ChangeNotifier {
  bool _isUpvoted = false;
  bool _isDownvoted = false;
  int _upvotes = 0;
  int _downvotes = 0;
  List<Map<String, dynamic>> _tagIssues = []; // Store issues for a specific tag
  List<Map<String, dynamic>> _leaderboard = []; // Store leaderboard data

  bool get isUpvoted => _isUpvoted;
  bool get isDownvoted => _isDownvoted;
  int get upvotes => _upvotes;
  int get downvotes => _downvotes;
  List<Map<String, dynamic>> get tagIssues => _tagIssues;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  void setInitialVotes(int upvotes, int downvotes) {
    _upvotes = upvotes;
    _downvotes = downvotes;
    notifyListeners();
  }

  // Upvote method connecting to the backend
  Future<void> upvoteIssue(String issueId) async {
    final url = Uri.parse('http://192.168.1.74:8000/upvote/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'issue_id': issueId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _upvotes = responseData['new_vote_count'];
        _isUpvoted = true;
        _isDownvoted = false; 
        notifyListeners();
      } else {
        print("Failed to upvote: ${response.body}");
      }
    } catch (e) {
      print("Error during upvote: $e");
    }
  }

    // Remove upvote method (NotUpvote)
  Future<void> notUpvoteIssue(String issueId) async {
    final url = Uri.parse('http://192.168.1.74:8000/notupvote/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'issue_id': issueId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _upvotes = responseData['new_vote_count'];
        _isUpvoted = false;
        notifyListeners();
      } else {
        print("Failed to remove upvote: ${response.body}");
      }
    } catch (e) {
      print("Error during removing upvote: $e");
    }
  }

  // Downvote method connecting to the backend
  Future<void> downvoteIssue(String issueId) async {
    final url = Uri.parse(
        'http://192.168.1.74:8000/downvote/'); // Adjust this if needed

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'issue_id': issueId}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _downvotes = responseData['new_vote_count'];
        _isDownvoted = true;
        _isUpvoted = false; // Reset upvote
        notifyListeners();
      } else {
        print("Failed to downvote: ${response.body}");
      }
    } catch (e) {
      print("Error during downvote: $e");
    }
  }

  // Remove downvote method (NotDownvote)
  Future<void> notDownvoteIssue(String issueId) async {
    final url = Uri.parse('http://192.168.1.74:8000/notdownvote/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'issue_id': issueId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _downvotes = responseData['new_vote_count'];
        _isDownvoted = false;
        notifyListeners();
      } else {
        print("Failed to remove downvote: ${response.body}");
      }
    } catch (e) {
      print("Error during removing downvote: $e");
    }
  }

  // Fetch initial vote status from the backend
  Future<void> fetchInitialVoteStatus(String issueId) async {
    final url = Uri.parse('http://192.168.1.74:8000/votestatus/$issueId/');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _isUpvoted = responseData['is_upvoted'];
        _isDownvoted = responseData['is_downvoted'];
        notifyListeners();
      } else {
        print("Failed to fetch vote status: ${response.body}");
      }
    } catch (e) {
      print("Error fetching vote status: $e");
    }
  }

  // Fetch issues for a specific tag
  Future<void> fetchIssuesByTag(String tagName) async {
    final url = Uri.parse('http://192.168.1.74:8000/issuewithtag/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'tag': tagName}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _tagIssues = List<Map<String, dynamic>>.from(
            responseData['issues']); // Decode JSON response
        notifyListeners(); // Notify listeners of state change
      } else {
        throw Exception('Failed to load issues for tag');
      }
    } catch (e) {
      print('Error fetching issues for tag: $e');
    }
  }

  // Fetch issues for leaderboard
  Future<void> fetchLeaderboard() async {
    final url = Uri.parse(
        'http://192.168.1.74:8000/leaderboard/'); // Update with the correct endpoint

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _leaderboard =
            List<Map<String, dynamic>>.from(responseData['leaderboard']);
        notifyListeners(); // Notify listeners of state change
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
    }
  }

  Future<void> createIssue({
    required String title,
    required String description,
    required List<String> tags,
    String? location,
    File? image,
  }) async {
    final url = Uri.parse('http://192.168.1.74:8000/createissue/');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Content-Type'] = 'application/json';

      request.fields['title'] = title;
      request.fields['description'] = description;
      if (tags.isNotEmpty) {
        request.fields['tags'] = json.encode(tags);
      }
      if (location != null) {
        request.fields['location'] = location;
      }
      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print("Issue created successfully.");
        notifyListeners();
      } else {
        print("Failed to create issue: ${response.statusCode}");
      }
    } catch (e) {
      print('Error creating issue: $e');
    }
  }
}
