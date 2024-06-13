import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video_streaming/firebase_options.dart';
import 'package:video_streaming/firebase_repo/firebase_repo.dart';
import 'package:video_streaming/presentation/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseRepo().signInAnonymously();
  runApp(const VideoStreamingApp());
}
