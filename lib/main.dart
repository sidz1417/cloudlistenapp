import 'package:audioplayers/audioplayers.dart';
import 'package:cloudlisten/pages/HandleScreen.dart';
import 'package:cloudlisten/providers/AudioProvider.dart';
import 'package:cloudlisten/providers/AuthProvider.dart';
import 'package:cloudlisten/providers/StorageProvider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider<AuthService>.value(
          value: AuthService(),
        ),
        StreamProvider<ConnectivityResult>.value(
          value: Connectivity().onConnectivityChanged,
        ),
        StreamProvider<AudioPlayerState>.value(
          value: currentPlayerState(),
        ),
        ChangeNotifierProvider<CurrentSong>.value(
          value: CurrentSong(),
        ),
        ChangeNotifierProvider<Uploads>.value(
          value: Uploads(),
        ),
      ],
      child: MaterialApp(
        title: 'CloudUploadApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: Color(0xff7b1fa2),
          cursorColor: Colors.black,
          fontFamily: 'Montserrat',
          textSelectionColor: Color(0xffc158dc),
          textSelectionHandleColor: Color(0xff7b1fa2),
        ),
        home: Consumer<AuthService>(
          builder:
              (BuildContext context, AuthService authService, Widget child) {
            return StreamProvider<String>.value(
              value: authService.onAuthStateChanged(),
              child: HandleScreen(),
            );
          },
        ),
      ),
    );
  }
}
