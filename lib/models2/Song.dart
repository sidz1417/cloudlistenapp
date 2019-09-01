import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class Song {
  final String songName;
  final String downloadUrl;

  Song({@required this.songName, @required this.downloadUrl});

  factory Song.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return Song(
      songName: data['songName'],
      downloadUrl: data['songLink'],
    );
  }

}