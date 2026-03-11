import 'package:flutter/foundation.dart';

class SessionExpiryNotifier {
  SessionExpiryNotifier._();

  static final SessionExpiryNotifier instance = SessionExpiryNotifier._();

  final ValueNotifier<int> eventCounter = ValueNotifier<int>(0);
  bool _hasPendingNotification = false;

  void notifySessionExpired() {
    if (_hasPendingNotification) return;
    _hasPendingNotification = true;
    eventCounter.value++;
  }

  void reset() {
    _hasPendingNotification = false;
  }
}
