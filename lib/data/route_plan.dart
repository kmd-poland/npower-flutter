import 'package:npower/data/visit.dart';

class RoutePlan {
  final List<Visit> visits;

  const RoutePlan({
    this.visits,
  });


  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    return RoutePlan(
        visits: json['visits'] != null
            ? List<Visit>.from(json['visits'].map((x) => Visit.fromJson(x)))
        : null
    );
  }
}