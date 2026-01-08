import 'dart:async';

import 'package:flutter/material.dart';

DeBouncer deBouncer = DeBouncer(milliSecond: 500);

class DeBouncer {
  DeBouncer({required this.milliSecond});
  final int milliSecond;
  Timer? timer;

  void run(VoidCallback action) {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    timer = Timer(Duration(milliseconds: milliSecond), action);
  }
}
