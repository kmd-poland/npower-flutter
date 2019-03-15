import 'dart:async';

import 'package:flutter/material.dart';
import 'package:npower/blocs/authentication_bloc.dart';
import 'package:npower/blocs/authentication_state.dart';
import 'package:npower/login_page.dart';
import 'package:npower/route_plan/map.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;

void main() => runApp(NPowerApp());

class NPowerApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  NPowerAppState createState() => new NPowerAppState();
}

class NPowerAppState extends State<NPowerApp> {
  AuthenticationBloc _bloc;

  @override
  initState() {
    super.initState();
    _bloc = AuthenticationBloc();
  }

  @override
  dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: getMainPage(),
        theme: ThemeData(
          // Define the default Brightness and Colors
          brightness: Brightness.light,
          primaryColor: Colors.lightBlue[800],
          accentColor: Colors.cyan[600],
        ));
  }

  Widget getMainPage() {
    return StreamBuilder<AuthenticationState>(
      stream: _bloc.authenticationState,
      builder: (context, AsyncSnapshot<AuthenticationState> snapshot) {
        if (snapshot.data == null) {
          return Container();
        }

        if (snapshot.data is Authenticated) {
          return MapPage();
        }

        return LoginPage(_bloc);
      },
    );
  }

}
