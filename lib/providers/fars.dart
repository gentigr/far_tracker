import 'package:flutter/material.dart';

import '../models/far.dart';

class Fars with ChangeNotifier {
  final List<Far> _items = [
    Far(
      id: 'FAR-1',
      date: '2022-11-05',
      content: 'The content of the Federal Aviation Regulations (v.1)',
    ),
    Far(
      id: 'FAR-2',
      date: '2022-11-06',
      content: 'The content of the Federal Aviation Regulations (v.2)',
    ),
    Far(
      id: 'FAR-3',
      date: '2022-11-07',
      content: 'The content of the Federal Aviation Regulations (v.3)',
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