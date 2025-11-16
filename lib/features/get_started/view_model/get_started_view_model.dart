import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import '../model/get_started_model.dart';

class GetStartedViewModel {
  final data = GetStartedModel(
    title:   AppStrings.appTitle,
    subtitle: AppStrings.subtitle,
  );

  void onGetStartedClick() {
    // Navigate logic
    // Example: Get.to(() => NextScreen());
    print(AppStrings.getStarted);
  }
}
