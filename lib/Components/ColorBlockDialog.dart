import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorBlocksDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorBlock(color: Colors.blue, text: "Block 1"),
            ColorBlock(color: Colors.green, text: "Block 2"),
            ColorBlock(color: Colors.red, text: "Block 3"),
          ],
        ),
      ),
    );
  }
}

class ColorBlock extends StatelessWidget {
  final Color color;
  final String text;

  ColorBlock({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: color,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}