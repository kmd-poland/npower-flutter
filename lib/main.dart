import 'dart:async';

import 'package:flutter/material.dart';
import 'package:npower/map.dart';
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
  StreamSubscription _sub;
  BuildContext navigationContext;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  initPlatformState() async {
    await initPlatformStateForStringUniLinks();
  }

  /// An implementation using a [String] link
  initPlatformStateForStringUniLinks() async {
    // Attach a second listener to the stream
    _sub = getLinksStream().listen((String link) {
      print('got link: $link');
      navigateToMap(link);
    }, onError: (err) {
      print('got err: $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    var home = Builder(builder: (context) {
      navigationContext = context;
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
                        launchBrowser();
                      },
                      child: const Text('LOG IN'),
                    ),
                  ]),
            ),
          ),
        ),
      );
    });

    return new MaterialApp(
        home: home,
        theme: ThemeData(
          // Define the default Brightness and Colors
          brightness: Brightness.dark,
          primaryColor: Colors.lightBlue[800],
          accentColor: Colors.cyan[600],
        ));
  }

  launchBrowser() async {
    var queryParameters = {
      "client_id": clientId,
      "scope": scopes,
      "response_type": "token",
      "redirect_uri": redirectUrl,
      "state": "state-" + new Uuid().v4(),
      "nonce": "bar"
    };

    var url =
        Uri.https(baseUthUrl, authorizationPath, queryParameters).toString();

    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  navigateToMap(String link) {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      if (link != null) {
        var token =
            link.substring(link.indexOf("access_token=") + 13, link.length);
        if (token == null) {
          return;
        }

        Navigator.push(navigationContext,
            MaterialPageRoute(builder: (context) => MapPage()));
      }
    } on PlatformException {
      print("Oh no, error.");
    }
  }
}
