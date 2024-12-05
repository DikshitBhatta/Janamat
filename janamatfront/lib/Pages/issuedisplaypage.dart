// Updated IssueDisplayPage
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';

class IssueDisplayPage extends StatefulWidget {
  final String issueId;
  final String date;
  final String location;
  final String title;
  final String imageUrl;
  final String description;
  final int initialVoteCount;

  IssueDisplayPage({
    required this.issueId,
    required this.date,
    required this.location,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.initialVoteCount,
  });

  @override
  _IssueDisplayPageState createState() => _IssueDisplayPageState();
}

class _IssueDisplayPageState extends State<IssueDisplayPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final votingProvider =
          Provider.of<VotingProvider>(context, listen: false);
      votingProvider.setInitialVotes(
          widget.initialVoteCount, 0); // Assuming no initial downvotes
      votingProvider
          .fetchInitialVoteStatus(widget.issueId); // Fetch initial vote status
    });
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
        child: Consumer<VotingProvider>(
          builder: (context, votingProvider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color:
                        votingProvider.isUpvoted ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    if (votingProvider.isUpvoted) {
                      votingProvider.notUpvoteIssue(widget.issueId);
                    } else {
                      votingProvider.upvoteIssue(widget.issueId);
                    }
                  },
                ),
                Text('${votingProvider.upvotes}'),
                IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color:
                        votingProvider.isDownvoted ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    if(votingProvider.isDownvoted) {
                      votingProvider.notDownvoteIssue(widget.issueId);
                    } else {
                      votingProvider.downvoteIssue(widget.issueId);
                    }
                  },
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
