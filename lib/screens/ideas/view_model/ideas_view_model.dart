import 'package:get/get.dart';
import 'package:love_connect/core/models/idea_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/ideas/model/ideas_model.dart';
import 'package:love_connect/screens/add_plan/view/add_plan_view.dart';

class IdeasViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final IdeasModel model = const IdeasModel();
  final RxList<IdeaModel> ideas = <IdeaModel>[].obs;
  final RxList<IdeaModel> filteredIdeas = <IdeaModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filteredIdeas.value = [];
    loadIdeas();
  }

  void loadIdeas() {
    ideas.value = _storageService.getDefaultIdeas();
    _applySearchFilter();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applySearchFilter();
  }

  void _applySearchFilter() {
    try {
      if (searchQuery.value.isEmpty) {
        filteredIdeas.value = List.from(ideas);
        return;
      }

      final query = searchQuery.value.toLowerCase();
      filteredIdeas.value = ideas.where((idea) {
        return idea.title.toLowerCase().contains(query) ||
            idea.category.toLowerCase().contains(query) ||
            idea.location.toLowerCase().contains(query);
      }).toList();
    } catch (e) {
      // If filtering fails, show all ideas
      filteredIdeas.value = List.from(ideas);
    }
  }

  void useIdea(IdeaModel idea) {
    // Navigate to Add Plan screen with idea pre-filled
    Get.to(
      () => AddPlanView(),
      arguments: {
        'title': idea.title,
        'place': idea.location,
        'type': idea.category,
      },
    );
    SnackbarHelper.showSafe(
      title: 'Idea Selected',
      message: '${idea.title} has been added to your plan',
    );
  }
}

