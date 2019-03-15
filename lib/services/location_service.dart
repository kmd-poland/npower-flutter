
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  Geolocator _geoLocator = Geolocator();

  static var _locationChanged = BehaviorSubject<Position>();
  Observable<Position> locationChanged = _locationChanged;

  LocationService() {

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 100);
    _geoLocator.getPositionStream(locationOptions)
      .listen((position) => {
        _locationChanged.add(position)
      });

  }

  void dispose() {
    _locationChanged.close();
  }
}
