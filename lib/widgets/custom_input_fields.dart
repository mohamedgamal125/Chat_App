import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String regEX;
  final String hintText;
  final bool obscureText;

  CustomTextFormField(
      {required this.onSaved,
      required this.regEX,
      required this.hintText,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: (newValue) => onSaved(newValue!),
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
      ),
      obscureText: obscureText,
      validator: (value) {
        return RegExp(regEX).hasMatch(value!) ? null : 'Enter Valid value';
      },
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(30, 29, 37, 1.0),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white54
        )
      ),

    );
  }
}


