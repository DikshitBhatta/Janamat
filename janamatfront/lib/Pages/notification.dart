import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Notifications')),
      ),
      body: FutureBuilder(
        future: Provider.of<VotingProvider>(context, listen: false).fetchNotification(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load notifications.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          return Consumer<VotingProvider>(
            builder: (context, votingProvider, child) {
              final notifications = votingProvider.notifications;

              if (notifications.isEmpty) {
                return const Center(
                  child: Text('No notifications available.'),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Colors.blueAccent,
                      ),
                      title: Text(notification['issue_title']),
                      subtitle: Text('${notification['activity']} on ${notification['timestamp']}'),
                      onTap: () {
                        // Navigate or handle notification tap
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(notification['issue_title']),
                            content: Text(notification['activity']),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
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
