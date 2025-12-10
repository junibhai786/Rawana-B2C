import 'package:flutter/material.dart';

import '../constants.dart';

//Search field widget
class SearchField extends StatelessWidget {
  final String hint;
  final Function(String) onChanged;
  final TextEditingController? controller;

  const SearchField({
    Key? key,
    required this.hint,
    required this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,

        border: outlineInputBorder(),

        // ... rest of your decoration
      ),
    );
  }
}

//outline input border

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(
      color: kColor1,
      width: 1.0,
    ),
  );
}
