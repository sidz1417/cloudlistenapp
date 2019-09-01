import 'package:audioplayers/audioplayers.dart';
import 'package:cloudlisten/models2/Song.dart';
import 'package:cloudlisten/providers/AudioProvider.dart';
import 'package:cloudlisten/providers/FireStoreProvider.dart';
import 'package:cloudlisten/providers/StorageProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flare_flutter/flare_actor.dart';

class SongsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SongsList(),
        Positioned(
            bottom: 0.0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 6,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: BackGround()),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CurrentSongText(),
                      PlaySlider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RewindButton(),
                          PlayPauseButton(),
                          ForwardButton()
                        ],
                      )
                    ],
                  ),
                )
              ],
            ))
      ],
    );
  }
}

class BackGround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentSong>(
        builder: (BuildContext context, CurrentSong song, Widget child) {
      if (song.currentSong != null)
        return Material(
          color: Colors.white,
          elevation: 20.0,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          shadowColor: Colors.black,
        );
      return Container();
    });
  }
}

class CurrentSongText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentSong>(
        builder: (BuildContext context, CurrentSong song, Widget child) {
      if (song.currentSong != null) return Text(song.currentSong.songName);
      return Container();
    });
  }
}

class PlaySlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final songDuration = Provider.of<SongDuration>(context);
    final currentPosition = Provider.of<CurrentPosition>(context);
    final song = Provider.of<CurrentSong>(context);
    if (song.currentSong != null)
      return Slider(
        activeColor: Theme.of(context).accentColor,
        inactiveColor: Colors.black,
        min: 0.0,
        max: songDuration.value,
        value: currentPosition.value,
        onChanged: (double value) {
          seekTo(value.toInt());
        },
      );
    return Container();
  }
}

class RewindButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final song = Provider.of<CurrentSong>(context);
    final songsList = Provider.of<List<Song>>(context);
    final playerState = Provider.of<AudioPlayerState>(context);
    if (song.currentSong != null && songsList != null)
      return IconButton(
        icon: Icon(Icons.fast_rewind),
        onPressed: (song.hasPrevSong(songsList))
            ? () {
                song.playPrevSong(songsList, playerState);
              }
            : null,
      );
    return Container();
  }
}

class PlayPauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final song = Provider.of<CurrentSong>(context);
    final currentPlayerState = Provider.of<AudioPlayerState>(context);

    if (song.currentSong != null)
      return IconButton(
        icon: Icon((currentPlayerState == AudioPlayerState.PLAYING)
            ? Icons.pause
            : Icons.play_arrow),
        onPressed: (currentPlayerState == AudioPlayerState.COMPLETED ||
                currentPlayerState == AudioPlayerState.STOPPED)
            ? null
            : () {
                if (currentPlayerState == AudioPlayerState.PAUSED)
                  resume();
                else
                  pause();
              },
      );
    return Container();
  }
}

class SongsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<List<Song>>(
      builder: (BuildContext context, List songsList, Widget child) {
        if (songsList == null) return Container();
        return ListView.builder(
          itemCount: songsList.length,
          itemBuilder: (BuildContext context, int index) {
            final song = songsList[index];
            return SongCard(song);
          },
        );
      },
    );
  }
}

class SongCard extends StatelessWidget {
  final Song song;
  SongCard(this.song);

  @override
  Widget build(BuildContext context) {
    final playerState = Provider.of<AudioPlayerState>(context, listen: false);
    final userId = Provider.of<String>(context, listen: false);
    final playingSongsList = Provider.of<List<Song>>(context, listen: false);
    final playingSong = Provider.of<CurrentSong>(context, listen: false);

    removeSongFromList() {
      updateDeleteFlag(userId: userId, songName: song.songName);
      playingSongsList.remove(song);
      delete(path: '$userId/${song.songName}');
    }

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-.85, 0),
          child: Icon(
            Icons.delete,
            size: 35.0,
            color: Colors.white,
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(.85, 0),
          child: Icon(
            Icons.delete,
            size: 35.0,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (DismissDirection direction) {
        if (playingSong.currentSong == null)
          removeSongFromList();
        else if (song.songName != playingSong.currentSong.songName)
          removeSongFromList();
        else if (song.songName == playingSong.currentSong.songName) {
          if (playingSong.hasNextSong(playingSongsList)) {
            playingSong.playNextSong(playingSongsList, playerState);
            removeSongFromList();
          } else {
            if (playingSongsList.length == 1) {
              stop();
              removeSongFromList();
              playingSong.setCurrentSong(null);
            } else {
              removeSongFromList();
              safePlay(song: playingSongsList[0], playerState: playerState);
              playingSong.setCurrentSong(playingSongsList[0]);
            }
          }
        }
      },
      child: Material(
        elevation: 7.0,
        child: Consumer<CurrentSong>(
          builder: (BuildContext context, CurrentSong currentPlayingSong,
                  Widget child) =>
              ListTile(
            title: Text(song.songName),
            onTap: () {
              currentPlayingSong.setCurrentSong(song);
              safePlay(playerState: playerState, song: song);
            },
            trailing: (currentPlayingSong.currentSong != null &&
                    currentPlayingSong.currentSong.songName == song.songName)
                ? Container(
                    width: 80.0,
                    child: FlareActor(
                      'animations/playAnimation.flr',
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      animation: 'play',
                      color: Theme.of(context).accentColor,
                    ),
                  )
                : Container(
                    width: 30.0,
                  ),
          ),
        ),
      ),
    );
  }
}

class ForwardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final song = Provider.of<CurrentSong>(context);
    final songsList = Provider.of<List<Song>>(context);
    final playerState = Provider.of<AudioPlayerState>(context);
    if (song.currentSong != null && songsList != null) {
      if (playerState != AudioPlayerState.COMPLETED)
        return IconButton(
            icon: Icon(Icons.fast_forward),
            onPressed: (song.hasNextSong(songsList))
                ? () {
                    song.playNextSong(songsList, playerState);
                  }
                : null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (song.hasNextSong(songsList)) {
          song.playNextSong(songsList, playerState);
        } else {
          if (songsList.isEmpty) {
            stop();
            song.setCurrentSong(null);
          } else {
            safePlay(song: songsList[0], playerState: playerState);
            song.setCurrentSong(songsList[0]);
          }
        }
      });
      return IconButton(icon: Icon(Icons.fast_forward), onPressed: null);
    }
    return Container();
  }
}
