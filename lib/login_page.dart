

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:npower/blocs/authentication_bloc.dart';
import 'package:npower/blocs/authentication_state.dart';

class LoginPage extends StatelessWidget {
  final AuthenticationBloc _authenticationBloc;

  LoginPage(this._authenticationBloc);

  @override
  Widget build(BuildContext context) {

      return new Scaffold(
        body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("images/lake.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: new Center(
            child: new Container(
              decoration: new BoxDecoration(
                  color: const Color(0xCCFFFFFF),
                  borderRadius:
                  new BorderRadius.all(const Radius.circular(50.0))),
              padding: EdgeInsets.only(top: 40, bottom: 40),
              height: 300.0,
              width: 300.0,
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Text("WELCOME",
                        style: Theme.of(context)
                            .textTheme
                            .display1
                            .merge(const TextStyle(color: Colors.black))),
                    new Text("PLEASE LOG IN FOR THE BEST LOGIN EXPERIENCE",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .body2
                            .merge(const TextStyle(color: Colors.black))),
                    RaisedButton(
                      onPressed: () {
                       _authenticationBloc.onAuthenticationRequired.add(AuthenticationRequest());
                      },
                      child: const Text('LOG IN'),
                    ),
                  ]),
            ),
          ),
        ),
      );

  }


}