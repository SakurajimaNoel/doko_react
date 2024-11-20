import 'dart:async';

import 'package:flutter/foundation.dart';

class Debounce {
  Duration delay;
  Timer? _timer;

  Debounce(this.delay);

  call(AsyncCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  dispose() {
    _timer?.cancel();
  }
}
