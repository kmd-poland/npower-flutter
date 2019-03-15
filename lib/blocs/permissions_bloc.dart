

import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class PermissionsBloc {

  final PermissionHandler _permissionHandler = PermissionHandler();
  var permissionsGrantedController = StreamController<bool>();
  var permissionsRequest = StreamController<String>();

  PermissionsBloc() {
    _checkAndRequestPermissions();
  }

  void _checkAndRequestPermissions() {
    _checkPermissions()
        .asStream().where((x) => !x)
        .listen((x) => _onPermissionNotGranted(x));
  }

  void _onPermissionNotGranted(bool isPermissionGranted) {
    // todo show congratulation message
    permissionsGrantedController.add(isPermissionGranted);
  }

  Future<Map<PermissionGroup, PermissionStatus>> showPermissionsDialog() async {
    return await _permissionHandler.requestPermissions([PermissionGroup.location]);
  }

  Future<bool> _checkPermissions() async {
    if (await _permissionHandler.checkPermissionStatus(PermissionGroup.location) != PermissionStatus.granted) {
      // Permission is not granted
      // Should we show an explanation?
      if (await _permissionHandler.shouldShowRequestPermissionRationale(PermissionGroup.contacts)) {
        // Show an explanation to the user *asynchronously* -- don't block
        // this thread waiting for the user's response! After the user
        // sees the explanation, try again to request the permission.
        permissionsRequest.add("Should you use the map, grant the permission to location for the app.");
      } else {
        // No explanation needed, we can request the permission.
        var permissionGranted = await showPermissionsDialog(); // await _permissionHandler.requestPermissions([PermissionGroup.location]);
        // check again if permission has been granted
        bool permissionGrantedEventually = false;
        for (var permissionGroup in permissionGranted.entries) {
          if (permissionGroup.value == PermissionStatus.granted) {
            permissionGrantedEventually = true;
            break;
          }
        }
        return permissionGrantedEventually;
      }
    } else {
      return true;
    }
    return false;
  }

  void dispose() {

  }
}