import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';

class IssueDisplayPage extends StatefulWidget {
  final String date;
  final String location;
  final String title;
  final String imageUrl;
  final String description;
  final int vote_count;

  IssueDisplayPage({
    required this.date,
    required this.location,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.vote_count,
  });

  @override
  _IssueDisplayPageState createState() => _IssueDisplayPageState();
}

class _IssueDisplayPageState extends State<IssueDisplayPage> {
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
            Image.asset('assets/issues/watersupply.jpg'),
            SizedBox(height: 16),
            Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '_authoname',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: Consumer<VotingProvider>(
          builder: (context, votingProvider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: votingProvider.isUpvoted ? Colors.green : Colors.grey,
                  ),
                  onPressed: votingProvider.toggleUpvote,
                ),
                Text('${votingProvider.upvotes}'),
                IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color: votingProvider.isDownvoted ? Colors.red : Colors.grey,
                  ),
                  onPressed: votingProvider.toggleDownvote,
                ),
                Text('${votingProvider.downvotes}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
