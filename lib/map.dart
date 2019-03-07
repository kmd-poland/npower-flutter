import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:npower/data/route_plan.dart';
import 'package:npower/data/visit.dart';
import 'package:npower/view_models/route_plan_view_model.dart';
import 'package:scrollable_bottom_sheet/scrollable_bottom_sheet.dart';


final LatLngBounds sydneyBounds = LatLngBounds(
  southwest: const LatLng(-34.022631, 150.620685),
  northeast: const LatLng(-33.571835, 151.325952),
);

final GlobalKey<ScaffoldState> _scaffoldKey = new
GlobalKey<ScaffoldState>();

class MapPage extends StatefulWidget {
  const MapPage();

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  MapPageState();

  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(-33.852, 151.211),
    zoom: 11.0,
  );

  bool _bottomSheetActive = false;
  String _currentState = "half";
  String _currentDirection = "up";

  final _biggerFont = const TextStyle(fontSize: 18.0);
  RoutePlanViewModel _viewModel = RoutePlanViewModelImpl();

  MapboxMapController mapController;
  CameraPosition _position = _kInitialPosition;
  bool _isMoving = false;
  bool _compassEnabled = true;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  String _styleString = MapboxStyles.MAPBOX_STREETS;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.Tracking;

  @override
  void initState() {
    // clicks from route plan would go there
    //routePlanList.addListener(() => _viewModel.routePlanItemItemSelected.add(routePlanList.selectedItem));

    super.initState();

  }

  @override
  void dispose() {
    mapController.removeListener(_onMapChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MapboxMap mapboxMap = MapboxMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: _kInitialPosition,
        trackCameraPosition: true,
        compassEnabled: _compassEnabled,
        cameraTargetBounds: _cameraTargetBounds,
        minMaxZoomPreference: _minMaxZoomPreference,
        styleString: _styleString,
        rotateGesturesEnabled: _rotateGesturesEnabled,
        scrollGesturesEnabled: _scrollGesturesEnabled,
        tiltGesturesEnabled: _tiltGesturesEnabled,
        zoomGesturesEnabled: _zoomGesturesEnabled,
        myLocationEnabled: _myLocationEnabled,
        myLocationTrackingMode: _myLocationTrackingMode,
        onMapClick: (point, latLng) async {
          print("${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
          List features = await mapController.queryRenderedFeatures(point, [],null);
          if (features.length>0) {
            print(features[0]);
          }
        },
        onCameraTrackingDismissed: () {
          this.setState(() {
            _myLocationTrackingMode = MyLocationTrackingMode.None;
          });
        }
    );

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("MAP!"),
          centerTitle: true,
        ),
        body: new Container(
          child: Row(
              children: <Widget>[
                Expanded(
                  child: mapboxMap,
                )
              ]
          ),
        )
    );
  }

  Widget _bottomSheetBuilder(BuildContext context) {
    final key = new GlobalKey<ScrollableBottomSheetState>();
    final ThemeData themeData = Theme.of(context);

    return Stack(children: [
      ScrollableBottomSheet(
        key: key,
        halfHeight: 400.0,
        minimumHeight: 150.0,
        autoPop: false,
        scrollTo: ScrollState.half,
        snapAbove: false,
        snapBelow: false,
        callback: (state) {
          if (state == ScrollState.minimum) {
            _currentState = "minimum";
            _currentDirection = "up";
          } else if (state == ScrollState.half) {
            if (_currentState == "minimum") {
              _currentDirection = "up";
            } else {
              _currentDirection = "down";
            }
            _currentState = "half";
          } else {
            _currentState = "full";
            _currentDirection = "down";
          }
        },
        child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 10.0),
            child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _getRoutePlanList()
            )
        ),
      ),
      Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          height: 50.0,
          child: Material(
            elevation: 15.0,
            child: IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  if (_currentState == "half") {
                    if (_currentDirection == "up") {
                      key.currentState.animateToFull(context);
                    } else {
                      key.currentState.animateToMinimum(context);
                    }
                  } else {
                    key.currentState.animateToHalf(context);
                  }
                }),
          ))
    ]);
  }

  Widget _getRoutePlanList() {
    return Container (
      height: 1000,
      child: StreamBuilder<RoutePlan>(
          stream: _viewModel.routePlanStream,
          builder: (context, AsyncSnapshot<RoutePlan> snapshot) {
            if (snapshot.hasError)
              return Text("Error: ${snapshot.error}");

            switch(snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text("Loading...");
              default:
                if (snapshot.data.visits.isEmpty)
                  return Text("Your route plan is empty.");
                return new ListView.builder(
                  //physics: NeverScrollableScrollPhysics(),
                  //primary: true,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: snapshot.data.visits.length,
                  itemBuilder: (context, i) {
                    return _buildRow(snapshot.data.visits[i]);
                  },

                );
            }

          }),
    );
  }

  void _showBottomSheet() {
    _scaffoldKey.currentState
    .showBottomSheet(_bottomSheetBuilder)
        .closed
        .whenComplete(() {
      if (mounted) {
        setState(() {
          _bottomSheetActive = false;
        });
      }
    });
  }

  Widget _buildRow(Visit visit) {
    return new GestureDetector(
      child: new ListTile(
        title: new Text(visit.firstName + " " + visit.lastName, style: _biggerFont),
      ),
      onTap: _onVisitSelected(visit),
    );

  }

  _onVisitSelected(Visit visit) {
    _viewModel.routePlanItemItemSelected.add(visit);
  }

  void _onMapChanged() {
    setState(() {
      _extractMapInfo();
    });
  }

  void _extractMapInfo() {
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  Widget _myLocationTrackingModeCycler() {
    final MyLocationTrackingMode nextType =
    MyLocationTrackingMode.values[(_myLocationTrackingMode.index + 1) % MyLocationTrackingMode.values.length];
    return FlatButton(
      child: Text('change to $nextType'),
      onPressed: () {
        setState(() {
          _myLocationTrackingMode = nextType;
        });
      },
    );
  }

  Widget _compassToggler() {
    return FlatButton(
      child: Text('${_compassEnabled ? 'disable' : 'enable'} compasss'),
      onPressed: () {
        setState(() {
          _compassEnabled = !_compassEnabled;
        });
      },
    );
  }

  Widget _latLngBoundsToggler() {
    return FlatButton(
      child: Text(
        _cameraTargetBounds.bounds == null
            ? 'bound camera target'
            : 'release camera target',
      ),
      onPressed: () {
        setState(() {
          _cameraTargetBounds = _cameraTargetBounds.bounds == null
              ? CameraTargetBounds(sydneyBounds)
              : CameraTargetBounds.unbounded;
        });
      },
    );
  }

  Widget _zoomBoundsToggler() {
    return FlatButton(
      child: Text(_minMaxZoomPreference.minZoom == null
          ? 'bound zoom'
          : 'release zoom'),
      onPressed: () {
        setState(() {
          _minMaxZoomPreference = _minMaxZoomPreference.minZoom == null
              ? const MinMaxZoomPreference(12.0, 16.0)
              : MinMaxZoomPreference.unbounded;
        });
      },
    );
  }

  Widget _setStyleToSatellite() {
    return FlatButton(
      child: Text('change map style to Satellite'),
      onPressed: () {
        setState(() {
          _styleString = MapboxStyles.SATELLITE;
        });
      },
    );
  }

  Widget _rotateToggler() {
    return FlatButton(
      child: Text('${_rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
      onPressed: () {
        setState(() {
          _rotateGesturesEnabled = !_rotateGesturesEnabled;
        });
      },
    );
  }

  Widget _scrollToggler() {
    return FlatButton(
      child: Text('${_scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
      onPressed: () {
        setState(() {
          _scrollGesturesEnabled = !_scrollGesturesEnabled;
        });
      },
    );
  }

  Widget _tiltToggler() {
    return FlatButton(
      child: Text('${_tiltGesturesEnabled ? 'disable' : 'enable'} tilt'),
      onPressed: () {
        setState(() {
          _tiltGesturesEnabled = !_tiltGesturesEnabled;
        });
      },
    );
  }

  Widget _zoomToggler() {
    return FlatButton(
      child: Text('${_zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        setState(() {
          _zoomGesturesEnabled = !_zoomGesturesEnabled;
        });
      },
    );
  }

  Widget _myLocationToggler() {
    return FlatButton(
      child: Text('${_myLocationEnabled ? 'disable' : 'enable'} my location'),
      onPressed: () {
        setState(() {
          _myLocationEnabled = !_myLocationEnabled;
        });
      },
    );
  }



  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.addListener(_onMapChanged);
    _extractMapInfo();
    _showBottomSheet();
    setState(() {});
  }
}