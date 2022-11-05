import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final String id;
  final String title;
  final String description;

  const FeatureItem(
      {super.key,
      required this.id,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            description,
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {},
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
