import 'package:flutter/material.dart';

import '../models/far.dart';

class Fars with ChangeNotifier {
  final List<Far> _items = [
    Far(
      id: 'FAR-1',
      date: '2022-11-05',
      content: 'The content of the Federal Aviation Regulations',
    ),
    Far(
      id: 'FAR-1',
      date: '2022-11-05',
      content: 'The content of the Federal Aviation Regulations',
    ),
    Far(
      id: 'FAR-1',
      date: '2022-11-05',
      content: 'The content of the Federal Aviation Regulations',
    ),
  ];

  List<Far> get items {
    return [..._items];
  }

  void add(Far far) {
    _items.add(far);
    notifyListeners();
  }
}