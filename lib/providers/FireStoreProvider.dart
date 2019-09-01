import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudlisten/models2/Song.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

final Firestore firestore = Firestore.instance;

Stream<List<Song>> getSongsList({@required String dbPath}) {

  return firestore.collection(dbPath).snapshots().map((querySnapshot) {

    return querySnapshot.documents
        .where((doc) => doc['deleted'] == false)
        .map((doc) => Song.fromFirestore(doc))
        .toList();
  });
}

void updateDeleteFlag({@required String userId, @required String songName}) {
  DocumentReference docRef = firestore.document('$userId/$songName');
  // firestore.runTransaction((txn) {
  //   txn.update(docRef, {'deleted': true});
  // });
  docRef.updateData({'deleted': true});
}

Future<bool> isDocExists({String dbPath}) async {
  DocumentSnapshot documentSnapshot = await firestore.document(dbPath).get();
  return documentSnapshot.exists;
}
