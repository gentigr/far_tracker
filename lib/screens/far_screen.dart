import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fars.dart';
import '../widgets/far_widget.dart';

class FarScreen extends StatelessWidget {
  static const routeName = '/fars/far';

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
      body: const Text('content'),
    );
  }
}
