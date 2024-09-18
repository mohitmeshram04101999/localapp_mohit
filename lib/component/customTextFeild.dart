import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  const CustomField({super.key,this.enabled = true,required this.controller,required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const  EdgeInsets.symmetric(horizontal: 20,vertical: 10), // Left padding
      child: TextField(
        enabled: enabled,
        controller: controller,
        decoration:  InputDecoration(
          contentPadding:const  EdgeInsets.fromLTRB(20, 15, 20, 15), // Padding for hint text
          hintText: hintText, // Placeholder text
        ),
      ),
    );
  }
}
