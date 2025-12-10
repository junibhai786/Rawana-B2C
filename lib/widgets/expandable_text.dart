// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 3,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontFamily: 'Inter'.tr,
        fontSize: 12,
        color: grey,
        fontWeight: FontWeight.w400);

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        bool textOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.text,
              style: textStyle,
              maxLines: isExpanded ? null : widget.trimLines,
              // overflow: TextOverflow.fade,
              textAlign: TextAlign.start,
            ),
            if (textOverflow) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isExpanded ? 'Show less'.tr : 'Show more'.tr,
                      style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 12,
                          fontFamily: 'Inter'.tr,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ),
            ]
          ],
        );
      },
    );
  }
}
