import 'package:code_of_federal_regulations/code_of_federal_regulations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../providers/fars.dart';
import '../widgets/subchapter_widget.dart';

class SubChaptersScreen extends StatelessWidget {
  static const routeName = '/fars/chapters/subchapters';

  Future<List<RegulationUnit>> _loadFarContent(BuildContext context) async {
    RegulationUnit unit = ModalRoute.of(context)!.settings.arguments as RegulationUnit;
    return unit.units;
  }

  @override
  Widget build(BuildContext context) {
    RegulationUnit unit = ModalRoute.of(context)!.settings.arguments as RegulationUnit;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(unit.title),
        ),
      ),
      body: FutureBuilder<List<RegulationUnit>>(
        future: _loadFarContent(context),
        builder: (BuildContext context,
            AsyncSnapshot<List<RegulationUnit>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var units = snapshot.data!;
            return ListView.builder(
              itemCount: units.length,
              itemBuilder: (ctx, i) => SubChapterWidget(unit: units[i]),
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
