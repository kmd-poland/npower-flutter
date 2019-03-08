import 'package:flutter/material.dart';
import 'package:npower/data/visit.dart';

class VisitPage extends StatefulWidget {
  Visit _visit;

  VisitPage(Visit visit) {
    _visit = visit;
  }

  @override
  State<VisitPage> createState() => VisitPageState(_visit);
}

class VisitPageState extends State<VisitPage> {
  Visit _visit;

  VisitPageState(Visit visit) {
    _visit = visit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your visit'),
      ),
      body: Hero(
        tag: _visit.avatar,
        transitionOnUserGestures: true,
        child: Center(
          child: CircleAvatar(
            backgroundImage: NetworkImage(_visit.avatar),
            radius: 100,
          ),
        ),
      ),
    );
  }
}
