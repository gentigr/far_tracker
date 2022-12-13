import 'package:code_of_federal_regulations/code_of_federal_regulations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../screens/subchapters_screen.dart';


class SubChapterWidget extends StatelessWidget {
  final RegulationUnit unit;
  const SubChapterWidget({super.key, required this.unit});

  Text _getTextWidget(RegulationUnit unit) {
    String content = unit.title;
    if (['SECTION', 'APPENDIX'].contains(unit.type)) {
      content = '${unit.title}\n${unit.element}';
    }
    return Text(
        content,
        textAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            if (!['SECTION', 'APPENDIX'].contains(unit.type)) {
              Navigator.of(context).pushNamed(SubChaptersScreen.routeName, arguments: unit);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: _getTextWidget(unit),
          ),
        ),
      ),
    );
  }
}
