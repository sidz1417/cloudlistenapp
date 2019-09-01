import 'dart:async';
import 'dart:io';
import 'package:cloudlisten/providers/FireStoreProvider.dart';
import 'package:cloudlisten/widgets/ErrorDialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

StorageUploadTask upload({@required String storagePath, @required File file}) {
  return firebaseStorage.ref().child(storagePath).putFile(file);
}

void uploadFile(
    BuildContext context, String userId, Uploads uploadSongs) async {
  try {
    File file =
        await FilePicker.getFile(fileExtension: 'mp3', type: FileType.CUSTOM);
    if (file != null) {
      String fileName = file.path.split('/').last;
      int index = uploadSongs.uploadsList
          .indexWhere((song) => song.songName == fileName);
      if (index >= 0) throw 'Only Unique filenames are allowed for upload';
      bool fileExists = await isDocExists(dbPath: '$userId/$fileName');
      if (fileExists) throw 'Only Unique filenames are allowed for upload';
      StorageUploadTask storageUploadTask =
          upload(storagePath: '$userId/$fileName', file: file);
      uploadSongs.addUploadSong(
          UploadSong(songName: fileName, storageUploadTask: storageUploadTask));
    } else
      return;
  } catch (error) {
    errorDialog(
        context: context,
        errorTitle: "Upload error",
        errorMessage: error.toString());
  }
}

void delete({@required String path}) {
  firebaseStorage.ref().child(path).delete();
}

class UploadSong with ChangeNotifier {
  final String songName;
  final StorageUploadTask storageUploadTask;

  UploadSong({@required this.songName, @required this.storageUploadTask});

  int bytesTransferred;
  int totalByteCount;
  StorageTaskEventType storageTaskEventType;

  Stream<StorageTaskEvent> storageTaskEvents() {
    return storageUploadTask.events.map((event) {
      bytesTransferred = event.snapshot.bytesTransferred;
      totalByteCount = event.snapshot.totalByteCount;
      storageTaskEventType = event.type;
      notifyListeners();
      return event;
    });
  }
}

class Uploads with ChangeNotifier {
  List<UploadSong> _uploads = [];

  List<UploadSong> get uploadsList => _uploads;

  set uploadsList(List<UploadSong> uploads) {
    _uploads = uploads;
    notifyListeners();
  }

  void addUploadSong(UploadSong uploadSong) {
    List<UploadSong> tempSongs = _uploads;
    tempSongs.add(uploadSong);
    StreamSubscription<StorageTaskEvent> storageTaskSubscription;
    storageTaskSubscription = uploadSong.storageTaskEvents().listen(
      (event) {
        if (event.type == StorageTaskEventType.failure ||
            event.type == StorageTaskEventType.success) {
          storageTaskSubscription.cancel();
          removeUploadSong(uploadSong.songName);
        }
      },
    );
    uploadsList = tempSongs;
  }

  void removeUploadSong(String uploadSongName) {
    List<UploadSong> tempSongs = _uploads;
    int index = tempSongs
        .indexWhere((uploadSong) => uploadSong.songName == uploadSongName);
    if (index == -1) return;
    tempSongs.removeAt(index);
    uploadsList = tempSongs;
  }
}
