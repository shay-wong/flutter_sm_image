import 'package:flutter/material.dart';
import 'package:flutter_sm_image/sm_image.dart';

class MImageExample extends StatelessWidget {
  const MImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MImageExample'),
      ),
      body: const Column(
        children: [
          Row(),
          MImage(
            'https://qcloudimg.tencent-cloud.cn/raw/2c6e4177fcca03de1447a04d8ff76d9c.png',
          )
        ],
      ),
    );
  }
}
