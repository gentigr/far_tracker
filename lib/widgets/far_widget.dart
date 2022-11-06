import 'package:flutter/material.dart';

import '../screens/title_screen.dart';

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
            Navigator.of(context)
                .pushNamed(TitleScreen.routeName, arguments: id);
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
