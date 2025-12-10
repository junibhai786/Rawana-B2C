import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/constants.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final double? inputLabelWidth;
  final double? inputFieldWidth;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final TextInputType? txKeyboardType;
  final bool isEnabled;
  final bool isReadOnly;
  final FocusNode? focusNode;
  final bool isFocused;
  final bool? obscureText;
  final bool check;
  final bool margin;
  final bool checking;
  final bool maxlength;
  final String prefix;
  final bool changeColor;
  final bool isDense;
  final String labelText;
  final void Function(String)? onChanged;
  final Function(String?)? onSaved;
  final int maxCheck;
  final void Function(String)? onFieldSubmitted;
  final Function()? onEditingComplete;
  final Function()? onTap;
  final Widget? suffix;
  final Widget? suffixicon;
  final Widget? prefixicon;
  final BoxConstraints? suffixConstraints;
  String? initialValue;

  CustomTextField({
    Key? key,
    this.hintText = "",
    this.maxCheck = 1,
    this.controller,
    this.labelText = "",
    this.inputFormatters,
    this.onTap,
    this.isRequired = false,
    this.isDense = false,
    this.maxlength = false,
    this.prefix = "",
    this.onChanged,
    this.checking = false,
    this.inputLabelWidth,
    this.inputFieldWidth,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.txKeyboardType,
    this.obscureText,
    this.validator,
    this.focusNode,
    this.check = false,
    this.margin = true,
    this.isFocused = false,
    this.onSaved,
    this.changeColor = false,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.suffix,
    this.suffixicon,
    this.suffixConstraints,
    this.initialValue, this.prefixicon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: inputFieldWidth,
          margin: margin == true
              ? EdgeInsets.only(left: 10, right: 10, bottom: 10)
              : EdgeInsets.zero,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: TextFormField(
            controller: controller,
            onFieldSubmitted: onFieldSubmitted,
            onEditingComplete: onEditingComplete,
            onChanged: onChanged,
            onSaved: onSaved,
            keyboardType: txKeyboardType ?? TextInputType.name,
            obscureText: obscureText ?? false,
            enabled: isEnabled == false ? false : true,
            readOnly: isReadOnly == false ? false : true,
            maxLines: maxCheck,
            onTap: onTap,
            maxLength: maxlength ? 11 : null,
            cursorColor: kSecondaryColor,
            style: GoogleFonts.spaceGrotesk(

              fontSize: 14,
              height: 1,
            ),
            decoration: InputDecoration(
              prefixText: prefix,
              border: outlineInputBorder(),
              disabledBorder: outlineInputBorder(),
              focusedBorder: outlineInputBorder(),
              enabledBorder: outlineInputBorder(),
              filled: true,
              fillColor: kBackgroundColor,
              hintText: hintText.tr,
              hintStyle: GoogleFonts.spaceGrotesk(

                color: Colors.grey,
                fontSize: 14,
              ),
              suffixIcon: suffixicon,
              prefixIcon: prefixicon,
              suffix: suffix,
            ),
            validator: validator,
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}

TextStyle textFieldStyle(
        {double? fontSize,
        FontWeight weight = FontWeight.w400,
        FontStyle style = FontStyle.normal,
        bool isHint = false,
        Color color = Colors.black}) =>
    GoogleFonts.spaceGrotesk(
      color: color,

      fontSize: fontSize,
      fontWeight: weight,
    );

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(
      color: kColor1,
    ),
  );
}

class DateInput extends StatelessWidget {
  final String? inputName;
  final TextEditingController? controller;
  final double? inputLabelWidth;
  final double? inputFieldWidth;
  final bool? isEnabled;

  const DateInput({
    Key? key,
    this.inputName,
    this.controller,
    this.inputLabelWidth,
    this.inputFieldWidth,
    this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: inputLabelWidth ?? 100,
          child: Text(
            inputName ?? '',
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        Container(
          width: inputFieldWidth ?? 100,
          color: Colors.white,
          child: TextFormField(
            style:  GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,

              fontSize: 15,
            ),
            enabled: isEnabled == true,
            keyboardType: TextInputType.datetime,
            controller: controller,
            onTap: () async {
              if (isEnabled == true) {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  // controller?.value = TextEditingValue(text: DateFormat('dd-MM-yyyy').format(picked).toString());
                }
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              isCollapsed: true,
            ),
          ),
        ),
      ],
    );
  }
}
