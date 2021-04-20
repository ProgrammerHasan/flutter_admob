import 'package:flutter/material.dart';

class MyNextPage extends StatefulWidget {
  final ads;
  MyNextPage({this.ads});
  @override
  _MyNextPageState createState() => _MyNextPageState();
}

class _MyNextPageState extends State<MyNextPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ads: ${widget.ads}'),
      ),
    );
  }
}
