import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video_streaming/di/injector.dart';
import 'package:video_streaming/domain/repositories/auth_repository.dart';
import 'package:video_streaming/firebase_options.dart';
import 'package:video_streaming/presentation/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initInjector();
  await i.get<AuthRepositoryInt>().signInAnonymously();
  runApp(const VideoStreamingApp());
}
