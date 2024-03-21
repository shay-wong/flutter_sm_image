import 'package:flutter/material.dart';
import 'package:flutter_sm_image/sm_image.dart';

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MCircleAvatar(
              source: null,
              package: 'example_package',
            ),
            MCircleAvatar(
              source: 'assets/images/avatar1.png',
              package: 'example_package',
            ),
            Text('Example Page'),
          ],
        ),
      ),
    );
  }
}
