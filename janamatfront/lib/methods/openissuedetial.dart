import 'package:flutter/material.dart';
import 'package:janamatfront/Pages/issuedetail.dart';

openissueDetail(BuildContext context, String tagName) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Issuedetail(tagName: tagName),
    ),
  );
}
