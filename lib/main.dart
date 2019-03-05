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
final redirectUrl = "npower.kmd.pl://callback";

void main() => runApp(NPowerApp());

class NPowerApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  NPowerAppState createState() => new NPowerAppState();
}

class NPowerAppState extends State<NPowerApp> {

  String _latestLink = 'Unknown';
  Uri _latestUri;

  StreamSubscription _sub;

  BuildContext navigationContext;

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

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
    //if (_type == UniLinksType.string) {
      await initPlatformStateForStringUniLinks();
    //} else {
    //  await initPlatformStateForUriUniLinks();
    //}
  }

  /// An implementation using a [String] link
  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      setState(() {
        _latestLink = link ?? 'Unknown';
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);
        } on FormatException {}
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestLink = 'Failed to get latest link: $err.';
        _latestUri = null;
      });
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      print('got link: $link');
      navigateToMap(link);
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;
    Uri initialUri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
      if (initialLink != null) initialUri = Uri.parse(initialLink);
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
      initialUri = null;
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
      initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = initialLink;
      _latestUri = initialUri;
    });
  }

  /// An implementation using the [Uri] convenience helpers
  initPlatformStateForUriUniLinks() async {
    // Attach a listener to the Uri links stream
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      setState(() {
        _latestUri = uri;
        _latestLink = uri?.toString() ?? 'Unknown';
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        _latestLink = 'Failed to get latest link: $err.';
      });
    });

    // Attach a second listener to the stream
    getUriLinksStream().listen((Uri uri) {
      print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest Uri
    Uri initialUri;
    String initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialUri = await getInitialUri();
      print('initial uri: ${initialUri?.path}'
          ' ${initialUri?.queryParametersAll}');
      initialLink = initialUri?.toString();
    } on PlatformException {
      initialUri = null;
      initialLink = 'Failed to get initial uri.';
    } on FormatException {
      initialUri = null;
      initialLink = 'Bad parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestUri = initialUri;
      _latestLink = initialLink;
    });
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = _latestUri?.queryParametersAll?.entries?.toList();

    var home = Builder(
      builder: (context) {
        navigationContext = context;
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("NPower!"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Press button to login.',
                ),
                Text(
                  'Please.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              launchBrowser();
            },
            child: Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      }
    );

    return new MaterialApp(
      home: home,
    );

  }

  launchBrowser() async {
    var queryParameters = {
      "client_id":clientId,
      "scope":scopes,
      "response_type":"token",
      "redirect_uri":redirectUrl,
      "state":"state-" + new Uuid().v4(),
      "nonce":"bar" };

    var url = Uri.https(baseUthUrl, authorizationPath, queryParameters).toString();

    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  navigateToMap(String link) {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {

      if (link != null) {
        var token = link.substring(
            link.indexOf("access_token=") + 13, link.length);
        if (token == null) {
          return;
        }

        Navigator.push(
            navigationContext, MaterialPageRoute(builder: (context) => MapPage()));
      }
    } on PlatformException {
      print("Oh no, error.");
    }
  }

}


