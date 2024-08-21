import 'package:flutter/material.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  static const double _padding = 16;

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(left: _padding, right: _padding, bottom: _padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("nearby page!"),
          ],
        ),
      ),
    );
  }
}
