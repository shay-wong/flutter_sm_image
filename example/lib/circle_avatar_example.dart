import 'package:example_package/example_package.dart';
import 'package:flutter/material.dart';
import 'package:sm_image/sm_image.dart';

import 'generated/assets.gen.dart';

class MCircleAvatarExample extends StatelessWidget {
  const MCircleAvatarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCircleAvatarExample'),
      ),
      body: Column(
        children: [
          const MCircleAvatar(
            source: null,
            placeholder: 'assets/images/avatar.png',
            diameter: 100,
            backgroundColor: Colors.amber,
          ),
          const MCircleAvatar(
            source: '',
            placeholder: 'assets/images/avatar.png',
            diameter: 100,
            backgroundColor: Colors.amber,
          ),
          MCircleAvatar(
            // source: '',
            placeholder: Assets.avatar1.keyName,
            foregroundColor: Colors.red,
            // foregroundSource: '',
            // foregroundPlaceholder: Assets.avatar.keyName,
            diameter: 100,
            backgroundColor: Colors.amber,
            child: const Text('123'),
          ),
          const MCircleAvatar(
            source: '123',
            placeholder: 'assets/images/avatar.png',
            diameter: 100,
            backgroundColor: Colors.amber,
          ),
          const Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: ExamplePage(),
          ),
          const Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
