import 'dart:async';

import 'package:flutter/material.dart';
import 'package:npower/blocs/authentication_bloc.dart';
import 'package:npower/blocs/authentication_state.dart';
import 'package:npower/blocs/permissions_bloc.dart';
import 'package:npower/login_page.dart';
import 'package:npower/route_plan/map.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:npower/view_models/main_view_model.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';

final baseUthUrl = "dev-910575.oktapreview.com";
final authorizationPath = "oauth2/default/v1/authorize";
final scopes = "openid profile";
final clientId = "0oajedfmef0ijCd6s0h7";
final redirectUrl = "npower-flutter://callback/token";

void main() => runApp(NPowerApp());

class NPowerApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  NPowerAppState createState() => new NPowerAppState();
}

class NPowerAppState extends State<NPowerApp> {
  AuthenticationBloc _bloc;

  PermissionsBloc _permissionsBloc;

  @override
  initState() {
    super.initState();
    _bloc = AuthenticationBloc();
    _permissionsBloc = PermissionsBloc();

    _permissionsBloc
        .permissionsGrantedController
        .stream
        .where((x) => !x)
        .listen((_) => {
      // todo we're good to go
    });

    _permissionsBloc
        .permissionsRequest
        .stream
        .listen((msg) => { _showPermissionsRationale(msg) });

  }

  @override
  dispose() {
    _bloc.dispose();
    _permissionsBloc.dispose();
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
      });
  }

  void _showPermissionsRationale(String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Permissions rationale"),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Get me to permissions"),
              onPressed: () {
                Navigator.of(context).pop();
                _permissionsBloc.showPermissionsDialog();
              },
            ),
          ],
        );
      },
    );
  }

}
