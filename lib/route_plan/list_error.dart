import 'package:flutter/material.dart';

class ListErrorWidget extends StatelessWidget {
  const ListErrorWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        alignment: FractionalOffset.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.warning,
              color: Colors.yellow[200],
              size: 80.0,
            ),
            Container(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                "There was an error fetching your route plan",
                style: TextStyle(color: Colors.yellow[100]),
              ),
            )
          ],
        ),
      ),
    );
  }
}