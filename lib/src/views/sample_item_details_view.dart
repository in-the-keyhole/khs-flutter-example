import 'package:flutter/material.dart';

import 'base_view.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: BaseView(
        child: const Center(
          child: Text('More Information Here'),
        ),
      ),
    );
  }
}
