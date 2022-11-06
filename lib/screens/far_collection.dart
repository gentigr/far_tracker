import 'package:flutter/material.dart';

class FarCollection extends StatelessWidget {

  static const routeName = '/far-collection';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
        child: Text('Federal Aviation Regulations'),
        ),
      ),
    );
  }
}