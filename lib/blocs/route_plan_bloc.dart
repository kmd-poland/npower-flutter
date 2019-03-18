import 'package:http/http.dart';
import 'package:npower/blocs/result_states.dart';
import 'package:npower/data/route.dart';
import 'dart:async';
import 'dart:convert';
import 'package:npower/data/route_plan.dart';
import 'package:npower/data/visit.dart';
import 'package:npower/services/location_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:geolocator/geolocator.dart';

class RoutePlanBloc {
  static final LocationService _locationService = LocationService();
  final Stream<ResultState> routePlan;
  final Stream<ResultState> route;

  factory RoutePlanBloc() {
    final routePlan = _routePlan().asBroadcastStream();
    final route = _route(routePlan);

    return RoutePlanBloc._(routePlan, route);
  }

  RoutePlanBloc._(this.routePlan, this.route);

  static Stream<ResultState> _routePlan() async* {
    yield ResultLoading();
    try {
      final result = await getRoutePlan();
      if (result.visits.isEmpty) {
        yield ResultEmpty();
      } else {
        yield ResultReady(result.visits);
      }
    } catch (e) {
      yield ResultError();
    }
  }

  static Stream<ResultState> _route(Stream<ResultState> routePlan) async* {
    yield ResultLoading();

    var streams = CombineLatestStream.combine2(
        _locationService.locationChanged,
        routePlan.where((x) => x is ResultReady),
        (currentPosition, routePlan) => Tuple2<Position, ResultReady<Visit>>(currentPosition, routePlan))
      .asyncMap((twoLocations) => getRoute(twoLocations.item1, twoLocations.item2.items.first))
      .map((directions) => {
        getDirectionsResult(directions)
    }).expand((x) => x);

    await for (var direction in streams)
        yield direction;

  }

  static ResultState getDirectionsResult(Directions directions) {
    if (directions == null) {
      return ResultEmpty();
    } else {
      if (directions.routes[0]?.geometry?.coordinates != null)
        return ResultReady(directions.routes[0].geometry.coordinates);
      else
        return ResultEmpty();
    }
  }

  static Future<RoutePlan> getRoutePlan() async {
    var url = "https://npower.azurewebsites.net/api/routeplan";
    var client = Client();

    var response = await client.get(url);
    if (response.statusCode == 200) {
      return RoutePlan.fromJson(json.decode(response.body));
    } else {
      throw Error();
    }
  }

  static Future<Directions> getRoute(Position start, Visit finish) async {
    print("Route from [${start.longitude}, ${start.latitude}] to ${finish.coordinates}");

    // todo get route

    var startOfTheRoute = "${start.longitude},${start.latitude}";
    var endOfTheRoute = "${finish.coordinates[0]},${finish.coordinates[1]}";
    var accessToken = "pk.eyJ1IjoibW11IiwiYSI6ImNqc2JqYXZsZDBjZWI0YnJwMTdoaHN4NXYifQ.he70cWtXMD5okEryWYiqbg";
    var mapboxDirectionsUrl = "https://api.mapbox.com/directions/v5/mapbox/driving/$startOfTheRoute;$endOfTheRoute?steps=true&geometries=geojson&access_token=$accessToken";

    var httpClient = new Client();
    try {
      var response = await httpClient.get(Uri.parse(mapboxDirectionsUrl));

      if (response.statusCode == 200) {
        return Directions.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } on FormatException catch(fe) {
      return null;
    } on Exception catch(e) {
      return null;
    }

  }

}
