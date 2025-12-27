import 'package:flutter/material.dart';

class EmailStyleProvider with ChangeNotifier {
  String _length = 'medium';
  String _formality = 'formal';
  String _tone = 'professional';

  String get length => _length;
  String get formality => _formality;
  String get tone => _tone;

  void setLength(String value) {
    _length = value;
    notifyListeners();
  }

  void setFormality(String value) {
    _formality = value;
    notifyListeners();
  }

  void setTone(String value) {
    _tone = value;
    notifyListeners();
  }

  void reset() {
    _length = 'medium';
    _formality = 'formal';
    _tone = 'professional';
    notifyListeners();
  }
}
