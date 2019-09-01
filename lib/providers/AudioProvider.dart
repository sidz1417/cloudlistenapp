import 'package:audioplayers/audioplayers.dart';
import 'package:cloudlisten/models2/Song.dart';
import 'package:flutter/material.dart';

AudioPlayer audioPlayer = AudioPlayer();

void play(String url) async {
  await audioPlayer.play(url);
}

void pause() async {
  await audioPlayer.pause();
}

void resume() async {
  await audioPlayer.resume();
}

void stop() async {
  await audioPlayer.stop();
}

void seekTo(int seconds) async {
  await audioPlayer.seek(Duration(seconds: seconds));
}

void safePlay({Song song, AudioPlayerState playerState}) {
  if (playerState == AudioPlayerState.PAUSED ||
      playerState == AudioPlayerState.PLAYING) {
    stop();
    play(song.downloadUrl);
  } else
    play(song.downloadUrl);
}

void deleteSong({@required Song song,@required List<Song> songsList}){
  songsList.remove(song);
}

Stream<AudioPlayerState> currentPlayerState() {
  return audioPlayer.onPlayerStateChanged;
}

Stream<double> getCurrentPosition() {
  return audioPlayer.onAudioPositionChanged.map((audioPosition) {
    return audioPosition.inSeconds.toDouble();
  });
}

Stream<double> getSongDuration() {
  return audioPlayer.onDurationChanged.map((audioPosition) {
    return audioPosition.inSeconds.toDouble();
  });
}

class CurrentSong extends ChangeNotifier {
  Song _currentSong;

  Song get currentSong => _currentSong;

  void setCurrentSong(Song song) {
    _currentSong = song;
    notifyListeners();
  }

  int getCurrentIndex(List<Song> songs) {
    if (songs.isEmpty) return -1;
    return songs.indexWhere((song) => _currentSong.songName == song.songName);
  }

  bool hasNextSong(List<Song> songs) {
    int currentIndex = getCurrentIndex(songs);
    return (currentIndex != -1 && currentIndex < songs.length - 1);
  }

  bool hasPrevSong(List<Song> songs) {
    int currentIndex = getCurrentIndex(songs);
    return (currentIndex != -1 && currentIndex > 0);
  }

  void playNextSong(List<Song> songs, AudioPlayerState playerState) {
    int currentIndex = getCurrentIndex(songs);
    setCurrentSong(songs[currentIndex + 1]);
    safePlay(song: songs[currentIndex + 1], playerState: playerState);
  }

  void playPrevSong(List<Song> songs, AudioPlayerState playerState) {
    int currentIndex = getCurrentIndex(songs);
    setCurrentSong(songs[currentIndex - 1]);
    safePlay(song: songs[currentIndex - 1], playerState: playerState);
  }

}

class SongDuration {
  double value;
  SongDuration(this.value);
}

class CurrentPosition {
  double value;
  CurrentPosition(this.value);
}
