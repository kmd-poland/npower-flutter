
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:npower/data/route_plan.dart';
import 'package:permission_handler/permission_handler.dart';

class MainViewModel {

  final PermissionHandler _permissionHandler = PermissionHandler();
  var permissionsGrantedController = StreamController<bool>();
  var permissionRationaleController = StreamController<String>();

  MainViewModel() {
    _checkAndRequestPermissions();
  }

  void showPermissionsDialog() async {
    var permissionGranted = await _permissionHandler.requestPermissions([PermissionGroup.location]);
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

  Future<bool> _checkPermissions() async {
    if (await _permissionHandler.checkPermissionStatus(PermissionGroup.location) != PermissionStatus.granted) {
      // Permission is not granted
      // Should we show an explanation?
      if (await _permissionHandler.shouldShowRequestPermissionRationale(PermissionGroup.contacts)) {
        // Show an explanation to the user *asynchronously* -- don't block
        // this thread waiting for the user's response! After the user
        // sees the explanation, try again to request the permission.
        permissionRationaleController.add("Should you use the map, grant the permission to location for the app.");
      } else {
        // No explanation needed, we can request the permission.
        var permissionGranted = await _permissionHandler.requestPermissions([PermissionGroup.location]);
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

  @override
  void dispose()
  {
    permissionsGrantedController.close();
    permissionRationaleController.close();
  }
}