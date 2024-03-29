import 'package:flutter/material.dart';
import 'package:sm_image/sm_image.dart';

class MImageExample extends StatelessWidget {
  const MImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MImageExample'),
      ),
      body: Column(
        children: [
          const Row(),
          Container(
            color: Colors.amber,
            child: MImage(
              'https://qcloudimg.tencent-cloud.cn/raw/2c6e4177fcca03de1447a04d8ff76d9c.png',
              // raduis: 60,
              // fit: BoxFit.cover,
              // clipMode: MImageClipMode.circle,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 10),
          Image(
            image: const MImage(
              'https://qcloudimg.tencent-cloud.cn/raw/2c6e4177fcca03de1447a04d8ff76d9c.png',
            ).image,
          )
        ],
      ),
    );
  }
}
