

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showMessage(BuildContext context,String data)
{
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
}