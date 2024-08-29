import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localapp/APIs/logInAPi.dart';
import 'package:localapp/component/logiin%20dailog.dart';
import 'package:localapp/component/show%20coustomMesage.dart';
import 'package:localapp/models/userModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:platform_device_id/platform_device_id.dart';

final profileProvider = StateNotifierProvider<ProfileProviderState,User?>((ref) {
  return ProfileProviderState(null);
});



class ProfileProviderState extends StateNotifier<User?>
{
  ProfileProviderState(super.state);

  final logInApi = LogApis();
  final _log = Logger();
  bool _loading = true;


  TextEditingController nameController= TextEditingController();
  TextEditingController phoneNumController= TextEditingController();

  Future<void> getUser(BuildContext context) async
  {
    String? deviceId = await PlatformDeviceId.getDeviceId;
    var resp = await logInApi.getUser(deviceId??"");

    if(resp.statusCode==200)
      {
        var decode = jsonDecode(resp.body);
        GetUserApiResponce data = GetUserApiResponce.fromJson(decode);
        _loading = false;
        state = data.data;
        if(state!.name==null||state!.mobileNumber1==null)
          {
            openLogInDialog(context);
          }
      }
    else
      {
        state = null;
        Logger().e("${resp.statusCode}\n${resp.body}");
      }

  }



  Future<void> updateProfile({
    required BuildContext context,
})async
{

  _log.e("Update ${phoneNumController.text} ${nameController.text} jhghjg");

  if(phoneNumController.text.trim().isEmpty ||nameController.text.trim().isEmpty)
    {
      return;
    }
  if(phoneNumController.text.trim().length!=10)
    {
      _log.e("in valid");
      showMessage(context, "Please Enter valid mobile number");
      return;
    }

  String? deviceId = await PlatformDeviceId.getDeviceId;
  var resp = await logInApi.updateProfile(name: nameController.text.trim(),mobileNumber1: phoneNumController.text.trim(),postById: deviceId);
  if(resp.statusCode==200)
    {

      getUser(context);
      phoneNumController.clear();
      nameController.clear();
      Navigator.pop(context);
    }
  else
    {
      showMessage(context, "${resp.statusCode}");
    }
}

}
