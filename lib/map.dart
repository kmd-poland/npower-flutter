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

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;

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
          print(
              "${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
          List features =
              await mapController.queryRenderedFeatures(point, [], null);
          if (features.length > 0) {
            print(features[0]);
          }
        },
        onCameraTrackingDismissed: () {
          this.setState(() {
            _myLocationTrackingMode = MyLocationTrackingMode.None;
          });
        });

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("MAP!"),
          centerTitle: true,
        ),
        body: new Container(
          child: Row(children: <Widget>[
            Expanded(
              child: mapboxMap,
            )
          ]),
        ),
      bottomSheetIsScrollControlled: true,
      bottomSheet: Builder( builder: (ctx) =>   _getBottomSheet(ctx),),


    );
  }


  Widget _getBottomSheet(BuildContext ctx){
    return _getRoutePlanList();
  }

  Widget _getRoutePlanList() {
    return Container(
      height: 100,
      child: StreamBuilder<RoutePlan>(


          stream: _viewModel.routePlanStream,
          builder: (context, AsyncSnapshot<RoutePlan> snapshot) {
            if (snapshot.hasError) return Text("Error: ${snapshot.error}");

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return SingleChildScrollView(
                   primary: true,
                    child:  Text("Loading..."));
              default:
                if (snapshot.data.visits.isEmpty)
                  return Text("Your route plan is empty.");
                return new ListView.builder(
                  //physics: NeverScrollableScrollPhysics(),
                  primary: true,
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


  Widget _buildRow(Visit visit) {
    return  ListTile(
      title: new Text(visit.firstName + " " + visit.lastName,
          style: _biggerFont),
      leading: new CircleAvatar(backgroundImage: NetworkImage(visit.avatar),),
      onTap: () => _onVisitSelected(visit),
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


  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    //mapController.addListener(_onMapChanged);
    _extractMapInfo();

  }
}
