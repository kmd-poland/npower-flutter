import 'dart:core';

class Visit {
  final String firstName;
  final String lastName;
  final DateTime startTime;
  final String address;
  final List<double> coordinates;

  const Visit({
    this.firstName,
    this.lastName,
    this.startTime,
    this.address,
    this.coordinates,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      firstName: json['firstName'],
      lastName: json['lastName'],
      startTime: DateTime.parse(json['startTime']),
      address: json['address'],
      coordinates: List<double>.from(json['coordinates'])
    );
  }
}