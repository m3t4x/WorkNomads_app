import 'package:get_it/get_it.dart';
import 'api_controller.dart';
import 'media_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register ApiController as singleton
  getIt.registerSingleton<ApiController>(ApiController());
  
  // Initialize the API controller
  await getIt<ApiController>().initialize();
  
  // Register MediaService as singleton
  getIt.registerSingleton<MediaService>(MediaService(getIt<ApiController>()));
  await getIt<MediaService>().initialize();
}
