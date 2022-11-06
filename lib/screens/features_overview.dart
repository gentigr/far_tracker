import 'package:flutter/material.dart';

import '../models/feature.dart';
import '../widgets/feature_widget.dart';

class FeaturesOverview extends StatelessWidget {
  final List<Feature> loadedFeatures = [
    Feature(
      id: 'far',
      title: 'FAR',
      description: 'The Federal Aviation Regulations',
    ),
    Feature(
      id: 'far',
      title: 'FAR',
      description: 'The Federal Aviation Regulations',
    ),
    Feature(
      id: 'far',
      title: 'FAR',
      description: 'The Federal Aviation Regulations',
    ),
    Feature(
      id: 'far',
      title: 'FAR',
      description: 'The Federal Aviation Regulations',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('Overview'),
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: loadedFeatures.length,
          itemBuilder: (ctx, i) => FeatureWidget(
              id: loadedFeatures[i].id,
              title: loadedFeatures[i].title,
              description: loadedFeatures[i].description),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
        ));
  }
}
