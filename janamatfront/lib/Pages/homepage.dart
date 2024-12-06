import 'package:flutter/material.dart';
import 'package:janamatfront/widgets/issuetype.dart'; // Import the IssueTypeGrid
import 'package:janamatfront/search/search.dart';

class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Scrollbar(
        thickness: 6.0, // Customize scrollbar thickness
        radius: Radius.circular(8.0), // Rounded corners for scrollbar
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // Ensures scrolling is always enabled
          child: Column(
            mainAxisSize: MainAxisSize.min, // Allow column to be as small as needed
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  margin: EdgeInsets.only(top: 16.0),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: Offset(0, 4),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.search),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (query) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(query: query),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IssueTypeGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
