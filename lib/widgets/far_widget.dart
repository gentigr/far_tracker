import 'package:flutter/material.dart';

import '../screens/fars_screen.dart';

class FarWidget extends StatelessWidget {
  final String id;
  final String date;
  final String content;

  const FarWidget(
      {super.key, required this.id, required this.date, required this.content});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // TODO: open FAR
          },
          child: Center(
            child: Text(
              date,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
