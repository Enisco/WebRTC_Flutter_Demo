import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_streaming/utils/logger.dart';

class FirebaseRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _roomsCollection = 'rooms';
  static const String _candidatesCollection = 'candidates';
  static const String _candidateUidField = 'uid';

  String? userId;

  Future<void> signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      userId = userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'operation-not-allowed':
          Logger.printRed(
            message: 'Anonymous auth hasn\'t been enabled for this project',
            filename: 'auth_repository',
            method: 'signInAnonymously',
            line: 18,
          );
          break;
        default:
          Logger.printRed(
            message: 'Unknown error',
            filename: 'auth_repository',
            method: 'signInAnonymously',
            line: 26,
          );
      }
    }
  }

  Future<String> createRoom({required RTCSessionDescription offer}) async {
    final roomRef = _db.collection(_roomsCollection).doc();
    final roomWithOffer = <String, dynamic>{'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    return roomRef.id;
  }

  Future<void> deleteRoom({required String roomId}) =>
      _db.collection(_roomsCollection).doc(roomId).delete();

  Future<void> setAnswer({
    required String roomId,
    required RTCSessionDescription answer,
  }) async {
    final roomRef = _db.collection(_roomsCollection).doc(roomId);
    final roomWithAnswer = <String, dynamic>{
      'answer': {'type': answer.type, 'sdp': answer.sdp}
    };
    await roomRef.update(roomWithAnswer);
  }

  Future<RTCSessionDescription?> getRoomOfferIfExists(
      {required String roomId}) async {
    final roomDoc = await _db.collection(_roomsCollection).doc(roomId).get();
    if (!roomDoc.exists) {
      return null;
    } else {
      final data = roomDoc.data() as Map<String, dynamic>;
      final offer = data['offer'];
      return RTCSessionDescription(offer['sdp'], offer['type']);
    }
  }

  Stream<RTCSessionDescription?> getRoomDataStream({required String roomId}) {
    final snapshots = _db.collection(_roomsCollection).doc(roomId).snapshots();
    final filteredStream = snapshots.map((snapshot) => snapshot.data());
    return filteredStream.map(
      (data) {
          Logger.printYellow(
            message: 'data: $data',
            filename: 'getRoomDataStream',
            method: 'getRoomDataStream',
            line: 60,
          );
        if (data != null && data['answer'] != null) {
          final session = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );
          Logger.printRed(
            message: 'type: ${session.type}\t sdp: ${session.sdp}',
            filename: 'getRoomDataStream',
            method: 'getRoomDataStream',
            line: 60,
          );
          return session;
        } else {
          return null;
        }
      },
    );
  }

  Stream<List<RTCIceCandidate>> getCandidatesAddedToRoomStream({
    required String roomId,
    required bool listenCaller,
  }) {
    final snapshots = _db
        .collection(_roomsCollection)
        .doc(roomId)
        .collection(_candidatesCollection)
        .where(_candidateUidField, isNotEqualTo: userId)
        .snapshots();

    final convertedStream = snapshots.map(
      (snapshot) {
        final docChangesList = listenCaller
            ? snapshot.docChanges
            : snapshot.docChanges
                .where((change) => change.type == DocumentChangeType.added);
        return docChangesList.map((change) {
          final data = change.doc.data() as Map<String, dynamic>;
          return RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
        }).toList();
      },
    );

    return convertedStream;
  }

  Future<void> addCandidateToRoom({
    required String roomId,
    required RTCIceCandidate candidate,
  }) async {
    final roomRef = _db.collection(_roomsCollection).doc(roomId);
    final candidatesCollection = roomRef.collection(_candidatesCollection);
    await candidatesCollection
        .add(candidate.toMap()..[_candidateUidField] = userId);
  }
}
