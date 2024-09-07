
import 'package:flutter/cupertino.dart';
import 'package:localapp/component/show%20coustomMesage.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:geolocator/geolocator.dart';


final locationPermmissionProvider = StateNotifierProvider<LocationPermissionNotifier,bool>((ref) {
  return LocationPermissionNotifier(false);
});


class LocationPermissionNotifier extends StateNotifier<bool> {
LocationPermissionNotifier(super.state);



Future<void> getLocationPermmision(BuildContext context) async
{
  var d = await Geolocator.requestPermission();
  Logger().e("location Permission $d");
  if(d==LocationPermission.always||d==LocationPermission.whileInUse)
    {
      state==true;
    }
  else
    {
      showMessage(context, "Please accept Location Permminsion");
      await getLocationPermmision(context);
    }

}

Future<Position?> getCurruntLocation(BuildContext context) async
{
  if(state)
    {
      var pos = await Geolocator.getCurrentPosition();
      return pos;
    }
  else
    {
      await getLocationPermmision(context);
      getCurruntLocation(context);
    }
  return null;
}
}
