import 'package:code_of_federal_regulations/code_of_federal_regulations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../providers/fars.dart';
import '../widgets/chapter_widget.dart';

class ChaptersScreen extends StatelessWidget {
  static const routeName = '/fars/chapters';

  Future<List<RegulationUnit>> _loadFarContent(String id) async {
    String cfrContent =
        await rootBundle.loadString('assets/title-14-at-2022-10-17.xml');
    CodeOfFederalRegulations cfr =
        CodeOfFederalRegulations.fromXmlString(cfrContent);
    return cfr.content.units[0].units;
  }

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context)!.settings.arguments as String;
    final farsData = Provider.of<Fars>(context);
    final fars = farsData.items;
    final far = fars.where((e) => e.id == id).first;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Title 14 - Aeronautics and Space'),
        ),
      ),
      body: FutureBuilder<List<RegulationUnit>>(
        future: _loadFarContent(id),
        builder: (BuildContext context,
            AsyncSnapshot<List<RegulationUnit>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var units = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: units.length,
              itemBuilder: (ctx, i) => ChapterWidget(unit: units[i]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 10,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            );
          }

          if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
