import 'package:firebase_database/firebase_database.dart';
import 'package:love_connect/core/models/plan_model.dart';

class PlansDatabaseService {
  static final PlansDatabaseService _instance =
      PlansDatabaseService._internal();
  factory PlansDatabaseService() => _instance;
  PlansDatabaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _usersPath = 'users';
  static const String _plansPath = 'plans';

  DatabaseReference _getUserPlansRef(String userId) {
    return _database.ref('$_usersPath/$userId/$_plansPath');
  }

  DatabaseReference _getPlanRef(String userId, String planId) {
    return _getUserPlansRef(userId).child(planId);
  }

  Future<bool> savePlan({
    required String userId,
    required PlanModel plan,
  }) async {
    try {
      final planData = plan.toJson();
      final planRef = _getPlanRef(userId, plan.id);

      await planRef.set(planData);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PlanModel>> getPlans(String userId) async {
    try {
      final snapshot = await _getUserPlansRef(userId).get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final value = snapshot.value;
      if (value is! Map) {
        return [];
      }

      final plansMap = value as Map<Object?, Object?>;
      final plans = <PlanModel>[];

      for (var entry in plansMap.entries) {
        try {
          final planData = entry.value;
          if (planData is Map) {
            final planJson = planData.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            final plan = PlanModel.fromJson(planJson);
            plans.add(plan);
          }
        } catch (e) {
          // return false;
        }
      }
      return plans;
    } catch (e) {
      return [];
    }
  }

  Future<bool> deletePlan({
    required String userId,
    required String planId,
  }) async {
    try {
      await _getPlanRef(userId, planId).remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<PlanModel>> getPlansStream(String userId) {
    return _getUserPlansRef(userId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <PlanModel>[];
      }

      final value = event.snapshot.value;
      if (value is! Map) {
        return <PlanModel>[];
      }

      final plansMap = value as Map<Object?, Object?>;
      final plans = <PlanModel>[];

      for (var entry in plansMap.entries) {
        try {
          final planData = entry.value;
          if (planData is Map) {
            final planJson = planData.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            final plan = PlanModel.fromJson(planJson);
            plans.add(plan);
          }
        } catch (e) {
          // return false;
        }
      }

      return plans;
    });
  }

  Future<bool> deleteAllPlans(String userId) async {
    try {
      await _getUserPlansRef(userId).remove();
      return true;
    } catch (e) {
      return false;
    }
  }
}
