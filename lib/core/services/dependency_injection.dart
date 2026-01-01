import 'package:get/get.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/services/journal_database_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/core/services/quotes_service.dart';
import 'package:love_connect/core/services/theme_service.dart';
import 'package:love_connect/core/services/error_handling_service.dart';
import 'package:love_connect/core/services/app_preferences_service.dart';

/// Dependency injection setup for the app
/// Uses Get.lazyPut for services to minimize memory usage on app start
class DependencyInjection {
  static Future<void> init() async {
    // Core services - lazy loaded (only created when first accessed)
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<LocalStorageService>(() => LocalStorageService(), fenix: true);
    Get.lazyPut<UserDatabaseService>(() => UserDatabaseService(), fenix: true);
    Get.lazyPut<PlansDatabaseService>(() => PlansDatabaseService(), fenix: true);
    Get.lazyPut<JournalDatabaseService>(() => JournalDatabaseService(), fenix: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.lazyPut<QuotesService>(() => QuotesService(), fenix: true);
    Get.lazyPut<AppPreferencesService>(() => AppPreferencesService(), fenix: true);
    
    // Theme service - permanent (needed throughout app lifecycle)
    //Get.put(ThemeService(), permanent: true);
    
    // Error handling service - permanent singleton
    Get.put(ErrorHandlingService(), permanent: true);
  }
}
