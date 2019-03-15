import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        padding: EdgeInsets.all(50),
        alignment: FractionalOffset.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}