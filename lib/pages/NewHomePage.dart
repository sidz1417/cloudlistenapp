import 'package:cloudlisten/models2/Song.dart';
import 'package:cloudlisten/pages/SongsPage.dart';
import 'package:cloudlisten/pages/UploadPage.dart';
import 'package:cloudlisten/providers/AudioProvider.dart';
import 'package:cloudlisten/providers/AuthProvider.dart';
import 'package:cloudlisten/providers/FireStoreProvider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewHomePage extends StatelessWidget {
  final List<String> _rules = [
    'How to upload songs\n',
    '1. Press the ' + ' button to upload a song.',
    '2. Songs can only be of .mp3 format & should be <= 10MB.',
    '3. Songs can only have unique names.',
    '4. Songs that fail conditions 2 & 3 will not upload.\n',
    'How to play songs:\n',
    '1. Press any song tile to play a song.',
    '2. To delete a song swipe left/right.\n',
    'Problems with version 1.0\n',
    '1.	The app must need internet to work. Offline mode is not supported currently.',
    '2.	Background play is not supported currently. The app needs to be in foreground to work.',
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context,listen: false);
    String userId = Provider.of<String>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cloud Upload'),
          leading:
              (authService.newUserStatus != null && authService.newUserStatus)
                  ? GestureDetector(
                      child: Container(
                        height: 40.0,
                        child: FlareActor(
                          'animations/newUserInfoAnimation.flr',
                          animation: 'seeInfo',
                          color: Colors.white,
                          fit: BoxFit.fill,
                          sizeFromArtboard: true,
                        ),
                      ),
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(child: Text('App Guidelines')),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    for (String rule in _rules) Text(rule)
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    'Understood',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    authService.newUserStatus = false;
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(child: Text('App Guidelines')),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    for (String rule in _rules) Text(rule)
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    'Understood',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
          centerTitle: true,
          backgroundColor: Theme.of(context).accentColor,
          actions: <Widget>[
            Consumer<CurrentSong>(
              builder: (BuildContext context, CurrentSong playingSong,
                      Widget child) =>
                  IconButton(
                tooltip: 'logout',
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  playingSong.setCurrentSong(null);
                  stop();
                  authService.signOut();
                },
              ),
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: 'Songs'),
              Tab(text: 'Uploads'),
            ],
          ),
        ),
        body: SafeArea(
          child: MultiProvider(
            providers: <SingleChildCloneableWidget>[
              StreamProvider<List<Song>>.value(
                value: getSongsList(dbPath: userId),
              ),
              StreamProvider<CurrentPosition>.value(
                initialData: CurrentPosition(0.0),
                value: getCurrentPosition()
                    .map((position) => CurrentPosition(position)),
              ),
              StreamProvider<SongDuration>.value(
                initialData: SongDuration(1.0),
                value:
                    getSongDuration().map((position) => SongDuration(position)),
              ),
            ],
            child: TabBarView(
              children: <Widget>[
                SongsPage(),
                UploadPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
