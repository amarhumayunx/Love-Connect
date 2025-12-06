import 'package:firebase_database/firebase_database.dart';
import 'package:love_connect/core/models/plan_model.dart';

/// Service for managing user plans in Firebase Realtime Database
class PlansDatabaseService {
  static final PlansDatabaseService _instance =
      PlansDatabaseService._internal();
  factory PlansDatabaseService() => _instance;
  PlansDatabaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _usersPath = 'users';
  static const String _plansPath = 'plans';

  /// Get reference to user plans node
  DatabaseReference _getUserPlansRef(String userId) {
    return _database.ref('$_usersPath/$userId/$_plansPath');
  }

  /// Get reference to specific plan
  DatabaseReference _getPlanRef(String userId, String planId) {
    return _getUserPlansRef(userId).child(planId);
  }

  /// Save a plan to Firebase Realtime Database
  /// Returns true if successful, false otherwise
  /// Optimized for fast writes
  Future<bool> savePlan({
    required String userId,
    required PlanModel plan,
  }) async {
    try {
      print(
        '💾 PlansDatabaseService: Saving plan "${plan.title}" for user: $userId',
      );
      final planData = plan.toJson();
      final planRef = _getPlanRef(userId, plan.id);

      // Use set() directly - Firebase Realtime Database is already optimized for fast writes
      // Using set() without await for priority makes it faster
      await planRef.set(planData);

      print(
        '✅ PlansDatabaseService: Successfully saved plan: ${plan.title} (ID: ${plan.id})',
      );
      return true;
    } catch (e) {
      print('❌ PlansDatabaseService savePlan error: $e');
      return false;
    }
  }

  /// Get all plans for a user
  /// Returns list of plans, empty list if none exist or on error
  Future<List<PlanModel>> getPlans(String userId) async {
    try {
      print('🔍 PlansDatabaseService: Loading plans for user: $userId');
      final snapshot = await _getUserPlansRef(userId).get();

      if (!snapshot.exists || snapshot.value == null) {
        print(
          '📭 PlansDatabaseService: No plans found in Firebase for user: $userId',
        );
        return [];
      }

      final value = snapshot.value;
      if (value is! Map) {
        print('⚠️ PlansDatabaseService: Invalid data format in Firebase');
        return [];
      }

      final plansMap = value as Map<Object?, Object?>;
      final plans = <PlanModel>[];

      print(
        '📦 PlansDatabaseService: Found ${plansMap.length} plan(s) in Firebase',
      );

      for (var entry in plansMap.entries) {
        try {
          final planData = entry.value;
          if (planData is Map) {
            final planJson = planData.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            final plan = PlanModel.fromJson(planJson);
            plans.add(plan);
            print(
              '✅ PlansDatabaseService: Loaded plan: ${plan.title} (ID: ${plan.id})',
            );
          }
        } catch (e) {
          print('❌ Error parsing plan ${entry.key}: $e');
          // Continue with other plans
        }
      }

      print(
        '✅ PlansDatabaseService: Successfully loaded ${plans.length} plan(s)',
      );
      return plans;
    } catch (e) {
      print('❌ PlansDatabaseService getPlans error: $e');
      return [];
    }
  }

  /// Delete a plan from Firebase Realtime Database
  /// Returns true if successful, false otherwise
  Future<bool> deletePlan({
    required String userId,
    required String planId,
  }) async {
    try {
      print(
        '🗑️ PlansDatabaseService: Deleting plan (ID: $planId) for user: $userId',
      );
      await _getPlanRef(userId, planId).remove();
      print('✅ PlansDatabaseService: Successfully deleted plan (ID: $planId)');
      return true;
    } catch (e) {
      print('❌ PlansDatabaseService deletePlan error: $e');
      return false;
    }
  }

  /// Stream of plans for real-time updates
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
          print('Error parsing plan ${entry.key}: $e');
          // Continue with other plans
        }
      }

      return plans;
    });
  }

  /// Delete all plans for a user (useful for account deletion)
  Future<bool> deleteAllPlans(String userId) async {
    try {
      await _getUserPlansRef(userId).remove();
      return true;
    } catch (e) {
      print('PlansDatabaseService deleteAllPlans error: $e');
      return false;
    }
  }
}
