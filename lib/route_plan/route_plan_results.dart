import 'package:flutter/material.dart';
import 'package:npower/data/visit.dart';

class RoutePlanResultWidget extends StatelessWidget {
  final List<Visit> items;
  final Function(Visit) onTap;

  final _biggerFont = const TextStyle(fontSize: 18.0);

  RoutePlanResultWidget({Key key, @required this.items, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        primary: true,
        padding: const EdgeInsets.all(10.0),
        itemCount: items.length,
        itemBuilder: (context, i) {
    return _buildRow(items[i]);
    });
  }

  Widget _buildRow(Visit visit) {
    return ListTile(
      title:
      new Text(visit.firstName + " " + visit.lastName, style: _biggerFont),
      leading:
      Hero(
        tag: visit.avatar,
        child:
        CircleAvatar(
          backgroundImage: NetworkImage(visit.avatar),
        ),
      ),
      onTap: () => onTap(visit),
    );
  }


}