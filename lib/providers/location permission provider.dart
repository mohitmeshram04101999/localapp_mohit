
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localapp/component/show%20coustomMesage.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';


final locationPermmissionProvider = StateNotifierProvider<LocationPermissionNotifier,bool>((ref) {
  return LocationPermissionNotifier(false);
});


class LocationPermissionNotifier extends StateNotifier<bool> {
LocationPermissionNotifier(super.state);


bool isDailogOpen = false;

Future<void> getLocationPermmision(BuildContext context) async
{
  var d = await Geolocator.requestPermission();
  Logger().e("location Permission $d");
  if(d==LocationPermission.always||d==LocationPermission.whileInUse)
    {
      state==true;
      return ;
    }

  else
    {
      isDailogOpen = true;
      await showDialog(context: context,barrierDismissible: false, builder: (context)=>AlertDialog(
        content: Column(mainAxisSize: MainAxisSize.min,children: [
          Icon(Icons.location_pin,size: 40,),
          Text("Plese provide location permission  provide ${d==LocationPermission.deniedForever?'Frome Settings':''}",textAlign: TextAlign.center,),
          if(d==LocationPermission.deniedForever)
            ElevatedButton(onPressed: ()async{
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.location);
            }, child: Text('Open Settings'))
        ],),
      ));
      isDailogOpen = false;
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
