import 'package:http/http.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import 'package:npower/data/route_plan.dart';
import 'package:npower/data/visit.dart';

class RoutePlanViewModelImpl extends RoutePlanViewModel {
  final _routePlanResults = PublishSubject<RoutePlan>();

  @override
  Observable<RoutePlan> get routePlanObservable => _routePlanResults.stream;

  @override
  void dispose() => _routePlanResults.close();

  Future getRoute() async {
    var url = "https://npower.azurewebsites.net/api/routeplan";
    RoutePlan routePlan;

    var client = Client();

    var response = await client.get(url);
    if (response.statusCode == 200) {
      routePlan = RoutePlan.fromJson(json.decode(response.body));
    }

    _routePlanResults.sink.add(routePlan);
  }
}

abstract class RoutePlanViewModel {
  Observable<RoutePlan> get routePlanObservable;

  getRoute();

  void dispose();
}
