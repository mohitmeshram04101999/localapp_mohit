
import 'package:flutter/cupertino.dart';
import 'package:localapp/component/show%20coustomMesage.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sim_data_plus/sim_data.dart';


final phoneNumberProvider = StateNotifierProvider<PhoneNumberNotifier,String?>((ref) {
  return PhoneNumberNotifier(null);
});


class PhoneNumberNotifier extends StateNotifier<String?> {
PhoneNumberNotifier(super.state);


Future<void> getSimNumber(BuildContext context)async
{

  var d = await SimDataPlugin.getSimData();
  Logger().e("1");

  for(var i in d.cards)
    {
      Logger().e("sim ${i.phoneNumber}");
    }
  Logger().e("2");

  if(d.cards.length==0)
    {
      return ;
    }


  if(d.cards.first.phoneNumber!=null||d.cards.first.phoneNumber!.isEmpty)
    {
      state = d.cards.first.phoneNumber;
    }

  else if(d.cards.length>1)
    {
   if(d.cards[1].phoneNumber!=null||d.cards.first.phoneNumber!.isEmpty)
  {
    state = d.cards[1].phoneNumber;
  }
    }

  if(state==null||state!.isEmpty)
    {
      showMessage(context, "No simCard Found");
    }
  Logger().e("3");

}


}
