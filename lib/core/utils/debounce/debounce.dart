import 'dart:async';

import 'package:flutter/foundation.dart';

class Debounce {
  final Duration delay;
  Timer? _timer;

  Debounce(this.delay);

  call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  dispose() {
    _timer?.cancel();
  }
}
