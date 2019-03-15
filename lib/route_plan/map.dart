import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:npower/data/visit.dart';
import 'package:npower/route_plan/list_empty.dart';
import 'package:npower/route_plan/list_error.dart';
import 'package:npower/route_plan/list_loading.dart';
import 'package:npower/route_plan/route_plan_results.dart';
import 'package:npower/blocs/result_states.dart';
import 'package:npower/blocs/route_plan_bloc.dart';
import 'package:npower/visit.dart';

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

  RoutePlanBloc _bloc;

  MapboxMapController mapController;
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

  Widget _bottomSheet;
  @override
  void initState() {
    super.initState();
    _bloc = RoutePlanBloc();
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

    if (_bottomSheet == null ) {
      _bottomSheet = _getRoutePlanList();
    }

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
      bottomSheet: _bottomSheet,
    );
  }



  Widget _getRoutePlanList() {
    return Container(
      height: 100,
      child: StreamBuilder<ResultState>(
          stream: _bloc.routePlan,
          initialData: ResultLoading(),
          builder: (context, AsyncSnapshot<ResultState> snapshot) {
            final state = snapshot.data;

            if (state is ResultEmpty) {
              return SingleChildScrollView(primary: true, child: EmptyWidget());
            }

            if (state is ResultError) {
              return SingleChildScrollView(
                  primary: true, child: ListErrorWidget());
            }

            if (state is ResultReady<Visit>) {
              return RoutePlanResultWidget(
                items: state.items,
                onTap: _onVisitSelected,
              );
            }

            return SingleChildScrollView(
                primary: true, child: LoadingWidget());
          }),
    );
  }

  _onVisitSelected(Visit visit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VisitPage(visit)),
    );
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }
}
