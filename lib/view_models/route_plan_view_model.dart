
import 'dart:_http';
import 'dart:async';

import 'dart:convert';

import 'package:npower/data/route_plan.dart';
import 'package:npower/data/visit.dart';

class RoutePlanViewModelImpl extends RoutePlanViewModel {
  var _routePlanController = StreamController<RoutePlan>.broadcast();
  var _routePlanItemItemSelectedController = StreamController<Visit>.broadcast();

  @override
  Sink get routePlanItemItemSelected => _routePlanItemItemSelectedController;

  @override
  Stream<bool> get outputIsRoutePlanReady => _routePlanController.stream
      .map((routePlan) => routePlan != null);

  @override
  Stream<RoutePlan> get routePlanStream => _routePlanController.stream;

  RoutePlanViewModelImpl() {
    _routePlanController.addStream(_getRoute().asStream());
    _routePlanItemItemSelectedController.stream.listen(onVisitSelected)
  }

  @override
  void dispose() => _routePlanController.close();

  Future<RoutePlan> _getRoute() async {
    var url = "https://npower.azurewebsites.net/api/routeplan";
    RoutePlan routePlan;
    var httpClient = new HttpClient();
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();

      await for (var contents in response.transform(Utf8Decoder())) {
        routePlan = RoutePlan.fromJson(json.decode(contents));
        return routePlan;
      }
    } on FormatException catch(fe) {
      print(fe);
    } on Exception catch(e) {
      print(e);
    }
    return routePlan;
  }

  void onVisitSelected(Visit visit) {
    print(visit);
  }
}

abstract class RoutePlanViewModel {
  Sink get routePlanItemItemSelected;
  Stream<bool> get outputIsRoutePlanReady;
  Stream<RoutePlan> get routePlanStream;

  void dispose();
}