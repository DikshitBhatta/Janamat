import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';
import 'package:janamatfront/Pages/issuedisplaypage.dart';

class SearchPage extends StatelessWidget {
  final String query;

  SearchPage({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder(
        future: Provider.of<VotingProvider>(context, listen: false)
            .searchIssues(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading search results: ${snapshot.error}'),
            );
          }
          return Consumer<VotingProvider>(
            builder: (context, votingProvider, _) {
              final searchResults = votingProvider.searchResults;
              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final issue = searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IssueDisplayPage(
                            issueId: issue['id'].toString(),
                            date: issue['created_at']?.toString() ?? 'Unknown Date',
                            location: issue['location']?.toString() ?? 'Unknown Location',
                            title: issue['title']?.toString() ?? 'No Title',
                            imageUrl: "http://192.168.1.74:8000${issue['imageUrl']}" ?? 'https://via.placeholder.com/150',
                            description: issue['description']?.toString() ?? 'No Description',
                            upvote_count: issue['upvote_count'] ?? 0,
                            downvote_count: issue['downvote_count'] ?? 0,
                            isUpvoted: issue['isUpvoted'] ?? false,
                            isDownvoted: issue['isDownvoted'] ?? false,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      tileColor: Colors.grey.shade100,
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              issue['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('${issue['upvote_count']}'),
                        ],
                      ),
                      trailing: Icon(
                        Icons.thumb_up,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
