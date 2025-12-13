import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

//section title

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.ktext,
  });

  final String ktext;

  @override
  Widget build(BuildContext context) {
    return Text(
      ktext,
      style:  GoogleFonts.spaceGrotesk(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      )
    );
  }
}
