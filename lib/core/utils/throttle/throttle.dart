import 'dart:async';

import 'package:flutter/foundation.dart';

class Throttle {
  final Duration interval;
  Timer? _timer;
  VoidCallback? latest;
  bool runAtEnd;

  Throttle(this.interval) : runAtEnd = false;

  /// this is used when we need to call the latest available callback
  /// after timer duration is completed
  Throttle.runAtEnd(this.interval) : runAtEnd = true;

  call(VoidCallback callback) {
    /// if existing timer is running
    /// save current callback to call when timer ends
    if (_timer != null) {
      if (runAtEnd) latest = callback;
      return;
    }

    /// directly run callback;
    callback();

    _timer = Timer(interval, _handleTimerEnd);
  }

  void _handleTimerEnd() {
    /// if latest callback is present run it
    if (latest != null) {
      latest!();
      latest = null;

      /// restart timer
      _timer = Timer(interval, _handleTimerEnd);
      return;
    }

    _timer = null;
  }

  dispose() {
    _timer?.cancel();
  }
}
