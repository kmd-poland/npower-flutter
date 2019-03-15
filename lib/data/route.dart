
class Directions {
  final List<MapboxRoute> routes;
  final String code;
  
  const Directions({
    this.routes,
    this.code
  });

  factory Directions.fromJson(Map<String, dynamic> json) {
    return Directions(
      routes: json["routes"] != null
        ? List<MapboxRoute>.from(json['routes'].map((x) => MapboxRoute.fromJson(x)))
          : null,
      code: json["code"] != null
        ? json["code"].toString()
          : null
    );
  }
}

class RouteFromString {
  final String geometry;

  const RouteFromString({
    this.geometry
  });

  factory RouteFromString.fromJson(Map<String, dynamic> json) {
    return RouteFromString(
        geometry: json["geometry"]
    );
  }
}

class MapboxRoute {
  final Geometry geometry;

  const MapboxRoute({
    this.geometry
  });

  factory MapboxRoute.fromJson(Map<String, dynamic> json) {
    return MapboxRoute(
        geometry: Geometry.fromJson(json["geometry"])
    );
  }
}

class Geometry {
  final List<Coordinate> coordinates;

  const Geometry({
    this.coordinates
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
        coordinates: json["coordinates"] != null
          ? List<Coordinate>.from(json["coordinates"].map((x) => Coordinate.fromJson(x)))
          : null
    );
  }

}

class Coordinate {
  final double longitude;
  final double latitude;

  const Coordinate({
    this.longitude,
    this.latitude
  });

  factory Coordinate.fromJson(List<dynamic> json) {
    return Coordinate(
      longitude: json[0],
      latitude: json[1]
    );
  }
}