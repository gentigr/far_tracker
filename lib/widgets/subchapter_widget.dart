import 'package:code_of_federal_regulations/code_of_federal_regulations.dart';
import 'package:flutter/material.dart';
import '../screens/subchapters_screen.dart';
import 'package:xml/xml.dart';

class TextTokenStyle {
  bool isItalic;

  TextTokenStyle([this.isItalic = false]);

  TextTokenStyle.clone(TextTokenStyle other): this(other.isItalic);

  factory TextTokenStyle.fromTag(String tag) {
    bool isItalic = false;
    if (tag == 'I') {
      isItalic = true;
    }
    return TextTokenStyle(isItalic);
  }

  TextTokenStyle absorb(TextTokenStyle other) {
    isItalic = other.isItalic;
    return this;
  }
}

class TextToken {
  final String data;
  final TextTokenStyle textTokenStyle;

  const TextToken({required this.data, required this.textTokenStyle});
}

class Content {
  final List<TextToken> textTokens;

  const Content({this.textTokens = const []});

  factory Content.fromXmlNodes(List<XmlNode> nodes) {
    final tokens = _processChildren(nodes, TextTokenStyle());
    return Content(textTokens: tokens);
  }

  static List<TextToken> _processChildren(List<XmlNode> nodes, TextTokenStyle style) {
    List<TextToken> tokens = [];
    // TODO: re-evaluate, should be safe since it is executed only for
    // paragraphOlds and for nodes that have at least text children, but still
    // not a good idea to rely on these constraints
    String parentTag = nodes.first.parentElement!.name.toString();
    final childProperty = TextTokenStyle.fromTag(parentTag);
    final newStyle = TextTokenStyle.clone(style).absorb(childProperty);
    for (final node in nodes) {
      if (node.nodeType == XmlNodeType.TEXT) {
        // leaf node, there is no more inner XML tags
        tokens.add(TextToken(data: node.text, textTokenStyle: newStyle));
      } else {
        tokens.addAll(_processChildren(node.children, newStyle));
      }
    }
    return tokens;
  }
}

class EnumeratedListIdentifier {
  final String value;
  final bool isItalic;

  bool get isEmpty {
    return value.isEmpty && !isItalic;
  }

  const EnumeratedListIdentifier({this.value = '', this.isItalic = false});

  factory EnumeratedListIdentifier.fromXmlStringStart(String content) {
    String pattern = r'^\((?<is_italic_start>(<I>)?)(?<enumerator>\w+)(?<is_italic_end>(<\/I>)?)\)';
    Iterable<RegExpMatch> matches = RegExp(pattern).allMatches(content);
    if (matches.isNotEmpty) {
      // TODO: check why the returned value is empty string instead of null
      bool isItalic = matches.elementAt(0).namedGroup('is_italic_start')!.isNotEmpty
          && matches.elementAt(0).namedGroup('is_italic_end')!.isNotEmpty;
      return EnumeratedListIdentifier(
          value: matches.elementAt(0).namedGroup('enumerator')!,
          isItalic: isItalic,
      );
    }
    return const EnumeratedListIdentifier();
  }

  @override
  bool operator==(Object other) {
    return other is EnumeratedListIdentifier && value == other.value && isItalic == other.isItalic;
  }

  @override
  int get hashCode => Object.hash(value, isItalic);

  @override
  String toString() {
    return '${value.isEmpty ? '-' : value}/${isItalic ? 'i' : '-'}';
  }
}

class ElementUi {
  @override
  String toString() {
    return '';
  }
}

class TableUi implements ElementUi {
  final int i;
  final String str;
  const TableUi(this.i, this.str);

  @override
  String toString() {
    return '$i $str';
  }
}

class ParagraphUi implements ElementUi {
  final int i;
  final String str;
  const ParagraphUi(this.i, this.str);

  @override
  String toString() {
    return '$i $str';
  }
}

abstract class ContentBlock<T> {
  final T value;

  const ContentBlock(this.value);

  T getValue() {
    return value;
  }
}

class TableBlock extends ContentBlock<int> {
  const TableBlock(int value): super(value);

  T asElement<T>(Representer v) {
    return v.asTable<T>(this);
  }
}

class ParagraphBlock extends ContentBlock<String> {
  const ParagraphBlock(String value): super(value);

  T asElement<T>(Representer v) {
    return v.asParagraph<T>(this);
  }
}

class Representer {
  ElementUi asTable<ElementUi>(TableBlock ib) {
    // print("invokeTable");
    return const TableUi(1, "table") as ElementUi;
  }
  ElementUi asParagraph<ElementUi>(ParagraphBlock pb) {
    // print("invokeParagraph");
    return const ParagraphUi(2, "paragraph") as ElementUi;
  }
}

// usage example:
// void main() {
//   TableBlock tb = TableBlock(100);
//   ParagraphBlock pb = ParagraphBlock('200');
//   Representer0 r = Representer0();
//
//   var t = tb.asElement<ElementUi>(r);
//   print(t);
//   var p = pb.asElement<ElementUi>(r);
//   print(p);
// }

class Paragraph {
  final Content core;
  // easier to keep it as list because there are not-enumerated paragraphs
  // which have the same identifier which cause the collision
  List<Paragraph> bullets;
  final EnumeratedListIdentifier enumeratedListIdentifier;

  bool get isEnumeratedListItem {
    return !enumeratedListIdentifier.isEmpty;
  }

  Paragraph({
    required this.core,
    List<Paragraph>? bullets,
    this.enumeratedListIdentifier = const EnumeratedListIdentifier()
  }) : bullets = bullets ?? [];

  factory Paragraph.fromXml(XmlElement element) {
    final enumeratorListIdentifier = EnumeratedListIdentifier.fromXmlStringStart(element.text);
    final core = Content.fromXmlNodes(element.children);
    return Paragraph(core: core, enumeratedListIdentifier: enumeratorListIdentifier);
  }
}

class NestedEnumeratedListPositionTrackerItem {
  final Paragraph root;
  final Paragraph node;

  const NestedEnumeratedListPositionTrackerItem({
    required this.root, required this.node
  });
}

class NestedEnumeratedListPositionTracker {

  List<NestedEnumeratedListPositionTrackerItem> listIdentifierToRoot;

  NestedEnumeratedListPositionTracker({
    List<NestedEnumeratedListPositionTrackerItem>? listIdentifierToRoot
  }) : listIdentifierToRoot = listIdentifierToRoot ?? [];

  bool get isEmpty {
    return listIdentifierToRoot.isEmpty;
  }

  Paragraph updateWithEnumeratedListIdentifier(
      Paragraph newIdentifier,
      Paragraph globalParagraph) {
    if (!newIdentifier.isEnumeratedListItem) {
      // when there are paragraphs within enumerated list item
      return listIdentifierToRoot.last.node;
    }

    for(int i = listIdentifierToRoot.length - 1; i >= 0; --i) {
      var currentIdentifier = listIdentifierToRoot[i];
      final nextIdentifier = EnumeratedListIdentifier(
          value: _nextIndexValue(currentIdentifier.node.enumeratedListIdentifier.value),
          isItalic: currentIdentifier.node.enumeratedListIdentifier.isItalic);
      if (nextIdentifier == newIdentifier.enumeratedListIdentifier) {
        listIdentifierToRoot.removeRange(i, listIdentifierToRoot.length);
        listIdentifierToRoot.add(NestedEnumeratedListPositionTrackerItem(root: currentIdentifier.root, node: newIdentifier));
        return currentIdentifier.root;
      }
    }
    final rootParagraph = listIdentifierToRoot.isEmpty ? globalParagraph : listIdentifierToRoot.last.node;
    listIdentifierToRoot.add(NestedEnumeratedListPositionTrackerItem(root: rootParagraph, node: newIdentifier));
    return rootParagraph;
  }

  static String _nextIndexValue(String indexValue) {
    // TODO: add/implement roman numbers
    return String.fromCharCode(indexValue.codeUnitAt(0) + 1);
  }

  @override
  String toString() {
    return listIdentifierToRoot.map((e) => "[${e.node.enumeratedListIdentifier} => root:${e.root.enumeratedListIdentifier}]").join(', ');
  }
}

class Section {
  final List<Paragraph> paragraphs;
  const Section({required this.paragraphs});

  factory Section.fromXml(Iterable<XmlElement> elements) {
    List<Paragraph> paragraphs = [];
    NestedEnumeratedListPositionTracker tracker = NestedEnumeratedListPositionTracker();

    for(final element in _getParagraphXmlElements(elements)) {
      var paragraph = Paragraph.fromXml(element);
      if (!paragraph.isEnumeratedListItem && tracker.isEmpty) {
        paragraphs.add(paragraph);
        continue;
      }

      // if a paragraph is a part of enumerated list
      if (paragraphs.isEmpty) {
        paragraphs.add(Paragraph(core: const Content()));
      }
      var rootParagraph = tracker.updateWithEnumeratedListIdentifier(
          paragraph, paragraphs.last);
      rootParagraph.bullets.add(paragraph);
    }

    return Section(paragraphs: paragraphs);
  }

  // TODO: implement conversion from RegulationUnit
  factory Section.fromRegulationUnit(RegulationUnit unit) {
    List<Paragraph> paragraphs = [];
    return Section(paragraphs: paragraphs);
  }

  static Iterable<XmlElement> _getParagraphXmlElements(Iterable<XmlElement> elements) {
    return elements.where((element) => element.name.toString() == 'P');
  }
}

class SubChapterWidget extends StatelessWidget {
  final RegulationUnit unit;
  const SubChapterWidget({super.key, required this.unit});

  TextSpan _formatTextContent(BuildContext context, TextToken token) {
    TextStyle style = DefaultTextStyle.of(context).style;
    if (token.textTokenStyle.isItalic) {
      style = style.merge(TextStyle(
        fontStyle: FontStyle.italic,
        backgroundColor: Colors.black.withOpacity(0.2),
      ));
    }

    return TextSpan(
      text: token.data,
      style: style,
    );
  }

  Row _constructHeaderRowNew(BuildContext context, List<TextToken> tokens) {
    List<TextSpan> ts = tokens.map((token) => _formatTextContent(context, token)).toList();
    var headerText = RichText(
      text: TextSpan(
        children: ts,
      ),
    );
    return Row(
      children: [
        Expanded(
            child: headerText
        ),
      ],
    );
  }

  List<Row> _constructContentRowsNew(BuildContext context, List<Paragraph> bullets) {
    List<Row> rows = [];
    for (final paragraph in bullets) {
      rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                        text: !paragraph.enumeratedListIdentifier.isEmpty ? "(${paragraph.enumeratedListIdentifier.value})" : "",
                        style: DefaultTextStyle.of(context).style
                    )
                ),
              ),
              Expanded(
                flex: 19,
                child: Column(
                  children: _formatParagraph(context, paragraph),
                ),
              ),
            ],
          )
      );
    }
    return rows;
  }

  List<Row> _formatParagraph(BuildContext context, Paragraph paragraph) {
    Row headerRow = _constructHeaderRowNew(context, paragraph.core.textTokens);
    List<Row> contentRows = _constructContentRowsNew(context, paragraph.bullets);
    Row? contentRow;
    if (contentRows.isNotEmpty) {
      contentRow = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 19,
            child: Column(
              children: contentRows,
            ),
          ),
        ],
      );
    }
    List<Row> rows = [headerRow];
    if (contentRow != null) {
      rows.add(contentRow);
    }
    return rows;
  }

  List<Row> _getContentRows(BuildContext context, RegulationUnit unit) {
    List<Row> rt = [];
    if (['SECTION', 'APPENDIX'].contains(unit.type)) {
      for (var paragraph in Section.fromXml(unit.element.childElements).paragraphs) {
        rt.addAll(_formatParagraph(context, paragraph));
      }
    }
    return rt;
  }

  @override
  Widget build(BuildContext context) {
    List<Row> rows = [];
    rows.add(
      Row(
        children: [
          Expanded(child:
            RichText(
              text: TextSpan(
                text: '${unit.title}\n\n',
                style: DefaultTextStyle.of(context).style,
              ),
            ),
          )
        ],
      ),
    );
    rows.addAll(_getContentRows(context, unit));

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
              children: rows,
            ),
          ),
        ),
      ),
    );
  }
}
