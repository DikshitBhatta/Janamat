import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';
import 'package:janamatfront/Pages/issuedisplaypage.dart';

class Leaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: FutureBuilder(
        future: Provider.of<VotingProvider>(context, listen: false).fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading leaderboard'),
            );
          }
          return Consumer<VotingProvider>(
            builder: (context, votingProvider, _) {
              final leaderboard = votingProvider.leaderboard;
              return ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final issue = leaderboard[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IssueDisplayPage(
                            issueId: issue['id'].toString(), // Ensure issueId is a String
                            date: issue['date']?.toString() ?? 'Unknown Date', // Ensure date is a String
                            location: issue['location']?.toString() ?? 'Unknown Location', // Ensure location is a String
                            title: issue['title']?.toString() ?? 'No Title', // Ensure title is a String
                            imageUrl: issue['imageUrl']?.toString() ?? 'https://via.placeholder.com/150', // Ensure imageUrl is a String
                            description: issue['description']?.toString() ?? 'No Description', // Ensure description is a String
                            initialVoteCount: issue['vote_count'] ?? 0, // Ensure initialVoteCount is an int
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
                          Text('${issue['vote_count']}'),
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
