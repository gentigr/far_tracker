import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fars.dart';
import '../widgets/far_widget.dart';

class FarScreen extends StatelessWidget {
  static const routeName = '/fars/far';

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context)!.settings.arguments as String;
    final farsData = Provider.of<Fars>(context);
    final fars = farsData.items;
    final far = fars.where((e) => e.id == id).first;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Federal Aviation Regulations'),
        ),
      ),
      body: Text(far.content),
    );
  }
}
