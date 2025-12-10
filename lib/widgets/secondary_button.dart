import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

//secondary button

class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.press,
  });

  final String text;
  final VoidCallback press;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  Color buttonColor = Colors.white;
  Color bordercolor = kPrimaryColor;

  void _onPressed() {
    setState(() {
      buttonColor = Color(0xffffee00);
      bordercolor = Color(0xffffee00); // Change button color to yellow
    });
    widget.press(); // Call the original press function
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        buttonColor = Colors.white;
        bordercolor = kPrimaryColor; // Reset to original color after 1 second
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(
          color: bordercolor,
          width: 1,
        ),
        elevation: 0,
      ),
      onPressed: _onPressed,
      child: Text(
        widget.text,
        style: GoogleFonts.spaceGrotesk(
          color: kPrimaryColor,
          fontSize: 14,

        ),
      ),
    );
  }
}
