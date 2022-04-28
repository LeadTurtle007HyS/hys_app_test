import 'package:get_it/get_it.dart';
import 'package:hys/SocialPart/Podcast/controllers/audio_player_controller.dart';
import 'package:hys/SocialPart/Podcast/controllers/path_controller.dart';
import 'package:hys/SocialPart/Podcast/controllers/record_controller.dart';
import 'package:hys/SocialPart/Podcast/controllers/settings_controller.dart';
import 'package:hys/SocialPart/Podcast/controllers/theme_controller.dart';
import 'package:hys/SocialPart/Podcast/controllers/timer_controller.dart';
import 'package:hys/SocialPart/Podcast/controllers/waveform_controller.dart';

import 'package:hys/SocialPart/Podcast/services/path_service.dart';
import 'package:hys/SocialPart/Podcast/services/record_service.dart';
import 'package:hys/SocialPart/Podcast/services/settings_service.dart';
import 'package:hys/SocialPart/Podcast/services/snackbar_service.dart';
import 'package:hys/SocialPart/Podcast/services/theme_pref_service.dart';
import 'package:hys/SocialPart/Podcast/services/theme_service.dart';
import 'package:hys/SocialPart/Podcast/services/timer_service.dart';
import 'package:hys/SocialPart/Podcast/services/waveform_service.dart';

import '../../../providers/navproviders.dart';
import 'audio_player_service.dart';
import 'logger_service.dart';
import 'navigation_service.dart';


GetIt locator = GetIt.instance;

void setupLocator() {
  Stopwatch stopwatch = Stopwatch()..start();
  locator.registerLazySingleton(() => NavigationService());
  locator .registerFactory<AudioPlayerController>(() => AudioPlayerController(""));
  locator.registerFactory<PathController>(() => PathController());
  locator.registerFactory<RecordController>(() => RecordController());
  locator.registerSingleton<NavBarIndex>(NavBarIndex());
  locator.registerFactory<TimerController>(() => TimerController());
  locator.registerFactory<ThemeController>(() => ThemeController());
  locator.registerFactory<SettingsController>(() => SettingsController());
  locator.registerFactory<WaveformController>(() => WaveformController());
  locator.registerSingleton<SettingsService>(SettingsService());
  locator.registerLazySingleton<ThemeService>(() => ThemeServicePrefs());
  locator.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());
  locator.registerLazySingleton<PathService>(() => PathService());
  locator.registerLazySingleton<RecordService>(() => RecordService());
  locator.registerLazySingleton<TimerService>(() => TimerService());
  locator.registerLazySingleton<SnackbarService>(() => SnackbarService());
  locator.registerLazySingleton<WaveformService>(() => WaveformService());
  logger.d('Locator setup took ${stopwatch.elapsedMilliseconds} ms');
  stopwatch.stop();
}
