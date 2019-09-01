import 'package:cloudlisten/providers/StorageProvider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BuildUploadSongsList(),
        Align(
          alignment: Alignment(.85, .9),
          child: UploadButton(),
        )
      ],
    );
  }
}

class BuildUploadSongsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uploads = Provider.of<Uploads>(context);
    return ListView.builder(
      itemCount: uploads.uploadsList.length,
      itemBuilder: (BuildContext context, int index) => Material(
        elevation: 7.0,
              child: ListTile(
          key: UniqueKey(),
          title: Text(uploads.uploadsList[index].songName),
          trailing: Container(
            width: 30.0,
            child: ChangeNotifierProvider<UploadSong>.value(
              value: uploads.uploadsList[index],
              child: Consumer<UploadSong>(
                builder:
                    (BuildContext context, UploadSong uploadSong, Widget child) {
                  if (uploadSong.storageTaskEventType == null)
                    return CircularProgressIndicator();
                  else if (uploadSong.storageTaskEventType ==
                          StorageTaskEventType.progress ||
                      uploadSong.storageTaskEventType ==
                          StorageTaskEventType.resume)
                    return CircularProgressIndicator(
                      value:
                          uploadSong.bytesTransferred / uploadSong.totalByteCount,
                    );
                  return Container();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<String>(context, listen: false);
    final uploadingSongs = Provider.of<Uploads>(context, listen: false);
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        uploadFile(context, userId, uploadingSongs);
      },
    );
  }
}
