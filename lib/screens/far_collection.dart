import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fars.dart';
import '../widgets/far_widget.dart';

class FarCollection extends StatelessWidget {

  static const routeName = '/far-collection';

  @override
  Widget build(BuildContext context) {
    final farsData = Provider.of<Fars>(context);
    final fars = farsData.items;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
        child: Text('Federal Aviation Regulations'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: fars.length,
        itemBuilder: (ctx, i) => FarWidget(
            id: fars[i].id,
            date: fars[i].date,
            content: fars[i].content),
      ),
    );
  }
}