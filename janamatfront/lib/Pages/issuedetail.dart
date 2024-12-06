// Issuedetail page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';
import 'package:janamatfront/Pages/issuedisplaypage.dart';

class Issuedetail extends StatelessWidget {
  final String tagName;

  const Issuedetail({Key? key, required this.tagName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final votingProvider = Provider.of<VotingProvider>(context);
    final tagIssues = votingProvider.tagIssues;
    if (tagIssues == null || tagIssues is! List) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Issues for $tagName'),
        ),
        body: Center(child: Text('No issues found for $tagName.')),
      );
    }
    print(tagIssues);
    return Scaffold(
      appBar: AppBar(
        title: Text('Issues for $tagName'),
      ),
      body: tagIssues.isEmpty
          ? Center(child: Text('No issues found for $tagName.'))
          : ListView.builder(
              itemCount: tagIssues.length,
              itemBuilder: (context, index) {
                final issue = tagIssues[index];
                final int votecount = issue['upvote_count'] ?? 0;
                final int downvote_count = issue['downvote_count'] ?? 0;
                print(issue);
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    title: Text(issue['title'] ?? 'No Title'),
                    subtitle: Text(
                      issue['description'] ?? 'No Description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 50.00, 
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '$votecount',
                                  style: TextStyle(fontSize: 15.0),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Icon(
                                Icons.thumb_up,
                                color: Colors.green,
                                size: 15.00,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '$downvote_count',
                                  style: TextStyle(fontSize: 15.0),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Icon(
                                Icons.thumb_down,
                                color: Colors.red,
                                size: 15.00,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                                              MaterialPageRoute(
                          builder: (context) => IssueDisplayPage(
                            issueId: issue['id']
                                .toString(), 
                            date: issue['created_at']?.toString() ??
                                'Unknown Date', 
                            location: issue['location']?.toString() ??
                                'Unknown Location', 
                            title: issue['title']?.toString() ??
                                'No Title', 
                            imageUrl: "http://192.168.1.74:8000${issue['imageUrl']}"  ??
                                'https://via.placeholder.com/150', 
                            description: issue['description']?.toString() ??
                                'No Description', 
                            upvote_count: issue['upvote_count'] ??
                                0, 
                            downvote_count: issue['downvote_count'] ??
                                0, 
                            isUpvoted: issue['voted'] ??
                                false, 
                            isDownvoted: issue['downvoted'] ??
                                false, 
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
