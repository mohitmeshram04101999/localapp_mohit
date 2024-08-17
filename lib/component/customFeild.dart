import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatters;

  const CustomField({this.formatters,this.inputType,required this.controller,this.hintText="",super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        keyboardType:inputType,
        inputFormatters:formatters,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const  EdgeInsets.symmetric(horizontal: 8),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,

            )
          ),
        ),
      ),
    );
  }
}
