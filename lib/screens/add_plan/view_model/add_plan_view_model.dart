import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/add_plan/model/add_plan_model.dart';
import 'package:uuid/uuid.dart';

class AddPlanViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final Rx<AddPlanModel> model = AddPlanModel().obs;
  final RxBool isSaving = false.obs;
  final String? planId; // If editing
  VoidCallback? onCloseCallback; // Optional callback for overlay mode

  AddPlanViewModel({this.planId, this.onCloseCallback});

  @override
  void onInit() {
    super.onInit();
    if (planId != null) {
      _loadPlan();
    }
  }

  Future<void> _loadPlan() async {
    final plans = await _storageService.getPlans();
    final plan = plans.firstWhereOrNull((p) => p.id == planId);
    if (plan != null) {
      model.value = AddPlanModel(
        title: plan.title,
        date: plan.date,
        time: plan.time,
        place: plan.place,
        type: plan.type.displayName,
      );
    }
  }

  void updateTitle(String value) {
    model.value = model.value.copyWith(title: value);
  }

  void updateDate(DateTime value) {
    model.value = model.value.copyWith(date: value);
  }

  void updateTime(TimeOfDay? value) {
    if (value != null) {
      final now = model.value.date;
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        value.hour,
        value.minute,
      );
      model.value = model.value.copyWith(time: dateTime);
    } else {
      model.value = model.value.copyWith(time: null);
    }
  }

  void updatePlace(String value) {
    model.value = model.value.copyWith(place: value);
  }

  void updateType(String value) {
    model.value = model.value.copyWith(type: value);
  }

  bool get isValid {
    return model.value.title.isNotEmpty &&
        model.value.place.isNotEmpty &&
        model.value.type.isNotEmpty;
  }

  Future<void> savePlan() async {
    if (!isValid) {
      SnackbarHelper.showSafe(
        title: 'Validation Error',
        message: 'Please fill in all required fields',
      );
      return;
    }

    isSaving.value = true;
    try {
      final planType = _getPlanTypeFromString(model.value.type);
      final plan = PlanModel(
        id: planId ?? const Uuid().v4(),
        title: model.value.title,
        date: model.value.date,
        time: model.value.time,
        place: model.value.place,
        type: planType,
      );

      await _storageService.savePlan(plan);
      if (onCloseCallback != null) {
        onCloseCallback!();
      } else {
        Get.back(result: true);
      }
      SnackbarHelper.showSafe(
        title: planId != null ? 'Plan Updated' : 'Plan Saved',
        message: 'Your plan has been saved successfully',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save plan. Please try again.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  PlanType _getPlanTypeFromString(String type) {
    switch (type.toUpperCase()) {
      case 'DINNER':
        return PlanType.dinner;
      case 'MOVIE':
        return PlanType.movie;
      case 'SURPRISE':
        return PlanType.surprise;
      case 'WALK':
        return PlanType.walk;
      case 'TRIP':
        return PlanType.trip;
      default:
        return PlanType.other;
    }
  }

  List<String> get planTypes => [
        'Surprise',
        'Dinner',
        'Movie',
        'Walk',
        'Trip',
        'Other',
      ];
}

