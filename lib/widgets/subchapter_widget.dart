import 'package:code_of_federal_regulations/code_of_federal_regulations.dart';
import 'package:flutter/material.dart';
import '../screens/subchapters_screen.dart';
import 'package:xml/xml.dart';

class ContentProperty {
  bool isItalic;

  ContentProperty([this.isItalic = false]);
  ContentProperty.clone(ContentProperty other): this(other.isItalic);
}

class Content {
  final String data;
  final ContentProperty cp;

  const Content({required this.data, required this.cp});
}

class ParagraphProperty {
  int indent;
  ParagraphProperty([this.indent = 0]);
}

class Paragraph {
  final List<Content> contents;
  final ParagraphProperty pp;
  List<Paragraph> subparagraphs = <Paragraph>[];

  Paragraph({required this.contents, required this.pp});
}

class IndexDescriptor {
  final String indexValue;
  final bool isItalic;
  final Paragraph paragraph;

  const IndexDescriptor({required this.indexValue, required this.isItalic, required this.paragraph});
}

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

  TextSpan _formatContent(BuildContext context, Content content) {
    TextStyle style = DefaultTextStyle.of(context).style;
    if (content.cp.isItalic) {
      style = style.merge(TextStyle(
        fontStyle: FontStyle.italic,
        backgroundColor: Colors.black.withOpacity(0.2),
      ));
    }

    return TextSpan(
      text: content.data,
      style: style,
    );
  }

  List<TextSpan> _processNodeList(BuildContext context, List<XmlNode> nodes) {
    List<TextSpan> ts = [];
    for(var node in nodes) {
      if (node.children.isEmpty) {
        ts.add(TextSpan(text: 'elements|${node.childElements.toString()}|\n'));
        ts.add(TextSpan(text: 'nodes|${node.children.toString()}|\n'));
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

  ContentProperty _buildContentProperty(String parentTag, ContentProperty cp) {
    ContentProperty properties = ContentProperty.clone(cp);
    if (parentTag == 'I') {
      properties.isItalic = true;
    }
    return properties;
  }

  List<Content> _processChildren(List<XmlNode> nodes, ContentProperty cp) {
    List<Content> contents = [];
    // TODO: re-evaluate, should be safe since it is executed only for
    // paragraphs and for nodes that have at least text children, but still
    // not a good idea to rely on these constraints
    String parentTag = nodes.first.parentElement!.name.toString();
    ContentProperty mergedProperty = _buildContentProperty(parentTag, cp);
    for (var node in nodes) {
      if (node.nodeType == XmlNodeType.TEXT) {
        // leaf node, there is no more inner XML tags
        contents.add(Content(data: node.text, cp: mergedProperty));
      } else {
        contents.addAll(_processChildren(node.children, mergedProperty));
      }
    }
    return contents;
  }

  String _nextIndexValue(String indexValue) {
    return String.fromCharCode(indexValue.codeUnitAt(0));
  }

  List<Paragraph> _process(Iterable<XmlElement> elements) {
    ContentProperty cp = ContentProperty();
    List<Paragraph> paragraphs = [];
    List<IndexDescriptor> indexDescriptors = [];
    for(var element in elements.where((element) => element.name.toString() == 'P')) {
      String format = r'^\((?<standard>\w+)\)|^\(<I>(?<italic>\w+)<\/I>\)';
      RegExp exp = RegExp(format);
      Iterable<RegExpMatch> matches = exp.allMatches(element.text);
      Paragraph? parentParagraph;
      if (matches.isNotEmpty) {
        bool currentIsItalic = matches.elementAt(0).namedGroup('italic') != null;
        String currentIndexValue = matches.elementAt(0).namedGroup(currentIsItalic ? 'italic' : 'standard')!;

        IndexDescriptor? actualIndexDescriptor;
        while(indexDescriptors.isNotEmpty) {
          var id = indexDescriptors.removeLast();
          if(_nextIndexValue(id.indexValue) == currentIndexValue
              && id.isItalic == currentIsItalic) {
            actualIndexDescriptor = id;
            break;
          }
        }
        if (actualIndexDescriptor == null) {
          parentParagraph = paragraphs.isNotEmpty ? paragraphs.last : null;
          if (parentParagraph == null) {
            // case when there is no paragraph before list starts
            Paragraph emptyParagraph = Paragraph(contents: <Content>[], pp: ParagraphProperty());
            paragraphs.add(emptyParagraph);
            parentParagraph = emptyParagraph;
          }
        } else {
          parentParagraph = actualIndexDescriptor.paragraph;
        }

        indexDescriptors.add(IndexDescriptor(indexValue: currentIndexValue, isItalic: currentIsItalic, paragraph: parentParagraph));
      }

      var content = _processChildren(element.children, cp);
      var newParagraph = Paragraph(contents: content, pp: ParagraphProperty());
      if (parentParagraph != null) {
        parentParagraph.subparagraphs.add(newParagraph);
      } else {
        paragraphs.add(newParagraph);
      }
    }
    return paragraphs;
  }

  Iterable<TextSpan> _format(BuildContext context, List<Paragraph> paragraphs) {
    List<TextSpan> ts = [];
    for (var paragraph in paragraphs) {
      ts.addAll(paragraph.contents.map((content) => _formatContent(context, content)));
    }
    return ts;
  }

  List<RichText> _generateRichTexts(BuildContext context, Paragraph paragraph) {
    List<TextSpan> ts = paragraph.contents.map((content) => _formatContent(context, content)).toList();
    List<RichText> rt = [RichText(
      text: TextSpan(
        children: ts,
      ),
    )];
    for(var subparagraph in paragraph.subparagraphs) {
      rt.addAll(_generateRichTexts(context, subparagraph));
    }
    return rt;
  }

  List<RichText> _getRichTextWidget(BuildContext context, RegulationUnit unit) {
    List<RichText> rt = [];
    if (['SECTION', 'APPENDIX'].contains(unit.type)) {
      // ts.addAll(_processNodeList(context, unit.element.children));
      for (var paragraph in _process(unit.element.childElements)) {
        rt.addAll(_generateRichTexts(context, paragraph));
      }
    }
    return rt;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [RichText(
                text: TextSpan(
                  text: '${unit.title}\n\n',
                  style: DefaultTextStyle.of(context).style,
                ),
              )] + _getRichTextWidget(context, unit),
            ),
          ),
        ),
      ),
    );
  }
}
