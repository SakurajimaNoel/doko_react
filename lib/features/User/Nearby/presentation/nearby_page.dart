import 'package:flutter/material.dart';

import '../../../../core/helpers/constants.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({
    super.key,
  });

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(Constants.padding),
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
