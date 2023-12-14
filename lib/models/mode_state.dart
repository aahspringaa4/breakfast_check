import 'package:flutter/foundation.dart';

class ModeState with ChangeNotifier {
  bool isEnglishMode;
  bool isDarkMode;

  ModeState({
    this.isEnglishMode = false, 
    this.isDarkMode = false
  });

  void changeLanguage() {
    isEnglishMode = !isEnglishMode;
    notifyListeners();
  }

  void changeLight() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}