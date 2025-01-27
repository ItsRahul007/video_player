import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double? fontSize;
  final int? maxLines;
  final FontWeight? fontWeight;
  final Color? color;

  const TextWidget(
      {super.key,
      required this.text,
      this.fontSize,
      this.fontWeight,
      this.color,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Colors.white,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines ?? 1,
    );
  }
}
