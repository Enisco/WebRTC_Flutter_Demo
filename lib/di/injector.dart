import 'package:get_it/get_it.dart';
import 'package:video_streaming/data/datasources/remote_datasource.dart';
import 'package:video_streaming/data/repositories/auth_repository.dart';
import 'package:video_streaming/data/repositories/room_repository.dart';
import 'package:video_streaming/domain/interactors/webrtc_interactor.dart';
import 'package:video_streaming/domain/repositories/auth_repository.dart';
import 'package:video_streaming/domain/repositories/room_repository.dart';
import 'package:video_streaming/presentation/pages/webrtc/webrtc_cubit.dart';

GetIt get i => GetIt.instance;

void initInjector() {
  initDataSourceModule();
  initRepositoryModule();
  initInteractorModule();
  initCubitModule();
}

void initDataSourceModule() {
  i.registerSingleton<RemoteDataSource>(RemoteDataSource());
}

void initRepositoryModule() {
  i.registerSingleton<AuthRepositoryInt>(AuthRepository(i.get()));
  i.registerSingleton<RoomRepositoryInt>(RoomRepository(i.get()));
}

void initInteractorModule() {
  i.registerFactory<WebrtcInteractor>(() => WebrtcInteractor(i.get()));
}

void initCubitModule() {
  i.registerFactory<WebrtcCubit>(() => WebrtcCubit(i.get()));
}
