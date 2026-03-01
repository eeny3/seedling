import 'package:get_it/get_it.dart';
import 'data/database_service.dart';
import 'services/notification_service.dart';
import 'services/audio_service.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  final dbService = DatabaseService();
  await dbService.init();
  getIt.registerSingleton<DatabaseService>(dbService);
  
  final notifService = NotificationService();
  await notifService.init();
  getIt.registerSingleton<NotificationService>(notifService);
  
  final audioService = AmbientAudioService();
  getIt.registerSingleton<AmbientAudioService>(audioService);
}
