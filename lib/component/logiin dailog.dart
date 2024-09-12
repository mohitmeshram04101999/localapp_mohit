import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localapp/component/customFeild.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localapp/providers/profieleDataProvider.dart';
import 'package:logger/logger.dart';

Future<void> openLogInDialog(BuildContext context) async {


  final style = TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.grey.shade800,
  );
  await showDialog(
      context: context,
      builder: (context) => WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide.none),

              // contentPadding: EdgeInsets.symmetric(horizontal: 8,vertical: 20),
              insetPadding: EdgeInsets.symmetric(horizontal: 30),

              content: Consumer(
                builder: (a, ref, c) {
                  var profileProviderState =
                      ref.watch(profileProvider.notifier);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //
                      Text(
                        "For us to show you relevant information, we need to know you better.",
                        style: style,
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      //
                      Text(
                        "Your name",
                        style: style,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomField(
                        hintText: "Type Your Name here",
                        controller: ref.watch(profileProvider.notifier).nameController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      //
                      Text(
                        "10 digit Whatsapp Number",
                        style: style,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomField(
                        validator: (s) {
                          return "sfdfgsdf";
                        },
                        inputType: TextInputType.number,
                        hintText: "10 digit Whatsapp Number",
                        controller: ref.watch(profileProvider.notifier).phoneNumController,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      //
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "This Whatsapp number will NOT be visible to other users in the app. it is solely used for creating your profile",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.blue.shade300,
                              fontSize: 13),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      //
                      SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) => Colors.grey.shade900),
                                  shape: MaterialStateProperty.resolveWith(
                                      (states) => RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(60)))),
                              onPressed: () {


                                ref
                                    .read(profileProvider.notifier)
                                    .updateProfile(
                                        context: context);
                              },
                              child: const Text("Submit")))
                    ],
                  );
                },
              ),
            ),
          ));
}
