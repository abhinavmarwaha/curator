import 'package:flutter/material.dart';

class AudioProvider with ChangeNotifier {
  int _curAudio = -1;

  AudioProvider(int curAudio) {
    _curAudio = curAudio;
  }

  int getCurAudio() => _curAudio;

  setCurAudio(int curAudio) {
    _curAudio = curAudio;
    notifyListeners();
  }
}
