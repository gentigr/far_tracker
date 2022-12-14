import 'package:code_of_federal_regulations/code_of_federal_regulations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../screens/subchapters_screen.dart';


class ChapterWidget extends StatelessWidget {
  final RegulationUnit unit;
  const ChapterWidget({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // TODO: go to subchapters
            Navigator.of(context)
                .pushNamed(SubChaptersScreen.routeName, arguments: unit);
          },
          child: Text(
            unit.title,
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }
}
