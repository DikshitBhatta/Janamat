// IssueTypeGrid page
import 'package:flutter/material.dart';
import 'package:janamatfront/Pages/issuedetail.dart';
import 'package:janamatfront/issuesimg/issueimg.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/providers/voting_provider.dart';

class IssueTypeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: issueImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                final tagName = issueLabels[index];
                final votingProvider = Provider.of<VotingProvider>(context, listen: false);

                // Show loading indicator while fetching data
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(child: CircularProgressIndicator()),
                );

                // Fetch issues by tag
                await votingProvider.fetchIssuesByTag(tagName);

                // Dismiss the loading indicator
                Navigator.pop(context);

                // Navigate to Issuedetail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Issuedetail(tagName: tagName),
                  ),
                );
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 100.0,
                      width: double.infinity,
                      child: Image.asset(
                        issueImages[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      issueLabels[index],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
