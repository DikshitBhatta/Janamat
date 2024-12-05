import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String uid;
  final DateTime date;
  final String title;
  final String issueType;
  final String description;
  final String? imagePath;

  Issue({
    required this.uid,
    required this.date,
    required this.title,
    required this.issueType,
    required this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': date,
      'title': title,
      'issueType': issueType,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Issue.fromMap(Map<String, dynamic> map) {
    return Issue(
      uid: map['uid'],
      date: (map['date'] as Timestamp).toDate(),
      title: map['title'],
      issueType: map['issueType'],
      description: map['description'],
      imagePath: map['imagePath'],
    );
  }
}
