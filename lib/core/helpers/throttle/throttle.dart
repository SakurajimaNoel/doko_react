import 'dart:async';

import 'package:flutter/foundation.dart';

class Throttle {
  Duration interval;
  Timer? _timer;
  bool _ready = false;

  Throttle(this.interval);

  call(VoidCallback callback) {
    if (!_ready) {
      // If the first call, set _ready after interval
      _timer = Timer(interval, () {
        _ready = true;
        callback();
      });
    } else if (_ready) {
      _ready = false;
      callback();
      _timer = Timer(interval, () {
        _ready = true;
      });
    }
  }

  dispose() {
    _timer?.cancel();
  }
}
