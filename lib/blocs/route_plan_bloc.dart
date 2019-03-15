import 'package:http/http.dart';
import 'package:npower/blocs/result_states.dart';
import 'dart:async';
import 'dart:convert';
import 'package:npower/data/route_plan.dart';

class RoutePlanBloc {
  final Stream<ResultState> routePlan;

  factory RoutePlanBloc() {
    final routePlan = _routePlan();

    return RoutePlanBloc._(routePlan);
  }

  RoutePlanBloc._(this.routePlan);

  static Stream<ResultState> _routePlan() async* {
    yield ResultLoading();
    try {
      final result = await getRoute();
      if (result.visits.isEmpty) {
        yield ResultEmpty();
      } else {
        yield ResultReady(result.visits);
      }
    } catch (e) {
      yield ResultError();
    }
  }

  static Future<RoutePlan> getRoute() async {
    var url = "https://npower.azurewebsites.net/api/routeplan";
    var client = Client();

    var response = await client.get(url);
    if (response.statusCode == 200) {
      return RoutePlan.fromJson(json.decode(response.body));
    } else {
      throw Error();
    }
  }
}
