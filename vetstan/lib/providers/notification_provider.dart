import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners();
  }

  void resetUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}
