import 'package:code_of_federal_regulations/code_of_federal_regulations.dart';
import 'package:flutter/material.dart';
import '../screens/subchapters_screen.dart';
import 'package:xml/xml.dart';

class SubChapterWidget extends StatelessWidget {
  final RegulationUnit unit;
  const SubChapterWidget({super.key, required this.unit});

  TextSpan _formatLeaf(BuildContext context, String text, XmlName name) {
    TextStyle style = DefaultTextStyle.of(context).style;
    switch(name.toString()) {
      case 'I':
        style = TextStyle(
          fontStyle: FontStyle.italic,
          backgroundColor: Colors.black.withOpacity(0.2),
        );
        break;
      default:
        break;
    }

    return TextSpan(
      text: text,
      style: style,
    );
  }

  List<TextSpan> _processNodeList(BuildContext context, List<XmlNode> nodes) {
    List<TextSpan> ts = [];
    for(var node in nodes) {
      if (node.children.isEmpty) {
        ts.add(TextSpan(text: '{${node.parentElement!.name.toString()}}'));
        ts.add(
          _formatLeaf(context, node.text, node.parentElement!.name)
        );
      } else {
        ts.addAll(_processNodeList(context, node.children));
      }
    }
    return ts;
  }

  RichText _getRichTextWidget(BuildContext context, RegulationUnit unit) {
    List<TextSpan> ts = [];
    if (['SECTION', 'APPENDIX'].contains(unit.type)) {
      ts.addAll(_processNodeList(context, unit.element.children));
    }
    return RichText(
      text: TextSpan(
        text: '${unit.title}\n\n',
        style: DefaultTextStyle.of(context).style,
        children: ts,
      ),
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
            child: _getRichTextWidget(context, unit),
          ),
        ),
      ),
    );
  }
}
