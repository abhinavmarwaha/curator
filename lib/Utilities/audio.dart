import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioTasks extends BackgroundAudioTask {
  MediaControl playControl = MediaControl(
    androidIcon: 'drawable/ic_action_play_arrow',
    label: 'Play',
    action: MediaAction.play,
  );
  MediaControl pauseControl = MediaControl(
    androidIcon: 'drawable/ic_action_pause',
    label: 'Pause',
    action: MediaAction.pause,
  );
  MediaControl skipToNextControl = MediaControl(
    androidIcon: 'drawable/ic_action_skip_next',
    label: 'Next',
    action: MediaAction.skipToNext,
  );
  MediaControl skipToPreviousControl = MediaControl(
    androidIcon: 'drawable/ic_action_skip_previous',
    label: 'Previous',
    action: MediaAction.skipToPrevious,
  );
  MediaControl stopControl = MediaControl(
    androidIcon: 'drawable/ic_action_stop',
    label: 'Stop',
    action: MediaAction.stop,
  );

  final _player = AudioPlayer();

  AudioTasks();

  @override
  onStart(Map<String, dynamic> params) async {
    print("inside onStart:" + params['url']);
    print("setting");
    await _player
        .setUrl(params['url'])
        .catchError((Object obj) => {print("seturl error")});
    print("playing");
    _player.play().catchError((Object obj) => {print("play error")});
    print("done");
    AudioServiceBackground.setState(
        playing: true,
        systemActions: [
          MediaAction.seekTo,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        ],
        controls: [pauseControl, stopControl],
        androidCompactActions: [0, 1, 3],
        position: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        processingState: AudioProcessingState.ready);

    // AudioServiceBackground.setMediaItem(mediaItem);
  }

  @override
  onStop() async {
    await _player.stop();
    await _player.dispose();
    await super.onStop();
  }

  @override
  onPlay() async {
    _player.play();
    AudioServiceBackground.setState(
        playing: true,
        systemActions: [
          MediaAction.seekTo,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        ],
        androidCompactActions: [0, 1, 3],
        position: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        controls: [pauseControl, stopControl],
        processingState: AudioProcessingState.ready);
  }

  @override
  onPause() {
    _player.pause();
    return AudioServiceBackground.setState(
        playing: false,
        systemActions: [
          MediaAction.seekTo,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        ],
        androidCompactActions: [0, 1, 3],
        position: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        controls: [playControl, stopControl],
        processingState: AudioProcessingState.ready);
  }

  // @override
  // onClick(MediaButton button) {}

  // @override
  // onSkipToNext() {
  //   // AudioServiceBackground.setMediaItem(mediaItem);
  // }

  // @override
  // onSkipToPrevious() {
  //   // AudioServiceBackground.setMediaItem(mediaItem);
  // }

  @override
  onSeekTo(Duration position) {
    return _player.seek(position);
  }

  // @override
  // onAudioFocusLost(AudioInterruption interruption) {}

  // @override
  // onAudioFocusGained(AudioInterruption interruption) {}

  // @override
  // void onAddQueueItem(MediaItem mediaItem) {
  //   //AudioServiceBackground.setQueue(queue)
  //   super.onAddQueueItem(mediaItem);
  // }
}
