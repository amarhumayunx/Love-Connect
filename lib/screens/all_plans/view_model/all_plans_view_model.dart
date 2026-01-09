import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/add_plan/view/add_plan_view.dart';

class AllPlansViewModel extends GetxController {
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();

  final RxList<PlanModel> plans = <PlanModel>[].obs;
  final RxList<PlanModel> filteredPlans = <PlanModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  
  // Search and filter
  final RxString searchQuery = ''.obs;
  final Rx<PlanType?> selectedTypeFilter = Rx<PlanType?>(null);
  final Rx<DateTime?> selectedDateFilter = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    filteredPlans.value = [];
    loadPlans();
  }

  Future<void> loadPlans() async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      List<PlanModel> loadedPlans = [];

      // CRITICAL: Only load plans if user is authenticated
      if (userId != null) {
        try {
          loadedPlans = await _plansDbService.getPlans(userId);
          // If Firebase returned plans, use them
          if (loadedPlans.isNotEmpty) {
            // Sort by date, upcoming first
            loadedPlans.sort((a, b) => a.date.compareTo(b.date));
            plans.value = loadedPlans;
            
            // Sync to user-specific local storage
            for (var plan in loadedPlans) {
              await _storageService.savePlan(plan, userId: userId);
            }
            _applyFilters();
            return;
          }
        } catch (e) {
          print('Failed to load plans from Firebase: $e');
          // Continue to try user-specific local storage as fallback
        }

        // If no plans from Firebase, check user-specific local storage
        final localPlans = await _storageService.getPlans(userId: userId);
        if (localPlans.isNotEmpty) {
          loadedPlans = localPlans;
        }
      } else {
        // No user authenticated - show empty plans
        loadedPlans = [];
      }

      // Sort by date, upcoming first
      loadedPlans.sort((a, b) => a.date.compareTo(b.date));
      plans.value = loadedPlans;
      _applyFilters();
    } catch (e) {
      print('Error loading plans: $e');
      plans.value = [];
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPlans() async {
    isRefreshing.value = true;
    await loadPlans();
    isRefreshing.value = false;
  }

  void onAddPlanTap() {
    HapticFeedback.lightImpact();
    Get.to(() => const AddPlanView())?.then((result) {
      if (result == true) {
        loadPlans();
      }
    });
  }

  void editPlan(PlanModel plan) {
    HapticFeedback.lightImpact();
    Get.to(() => AddPlanView(planId: plan.id))?.then((result) {
      if (result == true) {
        loadPlans();
      }
    });
  }

  Future<void> deletePlan(String planId) async {
    HapticFeedback.lightImpact();
    try {
      final userId = _authService.currentUserId;

      if (userId == null) {
        SnackbarHelper.showSafe(title: 'Error', message: 'User not authenticated');
        return;
      }

      // Delete from Firebase
      await _plansDbService.deletePlan(userId: userId, planId: planId);

      // Also delete from user-specific local storage
      try {
        await _storageService.deletePlan(planId, userId: userId);
      } catch (e) {
        print('Failed to delete plan from local storage: $e');
      }

      // Reload plans
      await loadPlans();

      SnackbarHelper.showSafe(
        title: 'Plan Deleted',
        message: 'Plan has been deleted successfully',
      );
    } catch (e) {
      SnackbarHelper.showSafe(title: 'Error', message: 'Failed to delete plan');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void updateTypeFilter(PlanType? type) {
    selectedTypeFilter.value = type;
    _applyFilters();
  }

  void updateDateFilter(DateTime? date) {
    selectedDateFilter.value = date;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedTypeFilter.value = null;
    selectedDateFilter.value = null;
    _applyFilters();
  }

  void _applyFilters() {
    try {
      List<PlanModel> filtered = List.from(plans);

      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        filtered = filtered.where((plan) {
          return plan.title.toLowerCase().contains(query) ||
              plan.place.toLowerCase().contains(query) ||
              plan.type.displayName.toLowerCase().contains(query);
        }).toList();
      }

      // Apply type filter
      if (selectedTypeFilter.value != null) {
        filtered = filtered.where((plan) {
          return plan.type == selectedTypeFilter.value;
        }).toList();
      }

      // Apply date filter
      if (selectedDateFilter.value != null) {
        final filterDate = selectedDateFilter.value!;
        filtered = filtered.where((plan) {
          return plan.date.year == filterDate.year &&
              plan.date.month == filterDate.month &&
              plan.date.day == filterDate.day;
        }).toList();
      }

      filteredPlans.value = filtered;
    } catch (e) {
      // If filtering fails, show all plans
      filteredPlans.value = List.from(plans);
    }
  }
}
