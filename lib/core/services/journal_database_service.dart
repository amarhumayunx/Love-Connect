import 'package:firebase_database/firebase_database.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';

class JournalDatabaseService {
  static final JournalDatabaseService _instance =
      JournalDatabaseService._internal();
  factory JournalDatabaseService() => _instance;
  JournalDatabaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _usersPath = 'users';
  static const String _journalPath = 'journal';

  DatabaseReference _getUserJournalRef(String userId) {
    return _database.ref('$_usersPath/$userId/$_journalPath');
  }

  DatabaseReference _getJournalEntryRef(String userId, String entryId) {
    return _getUserJournalRef(userId).child(entryId);
  }

  Future<bool> saveJournalEntry({
    required String userId,
    required JournalEntryModel entry,
  }) async {
    try {
      final entryData = entry.toJson();
      final entryRef = _getJournalEntryRef(userId, entry.id);

      await entryRef.set(entryData);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<JournalEntryModel>> getJournalEntries(String userId) async {
    try {
      final snapshot = await _getUserJournalRef(userId).get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final value = snapshot.value;
      if (value is! Map) {
        return [];
      }

      final entriesMap = value as Map<Object?, Object?>;
      final entries = <JournalEntryModel>[];

      for (var entry in entriesMap.entries) {
        try {
          final entryData = entry.value;
          if (entryData is Map) {
            final entryJson = entryData.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            final journalEntry = JournalEntryModel.fromJson(entryJson);
            entries.add(journalEntry);
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
      return entries;
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteJournalEntry({
    required String userId,
    required String entryId,
  }) async {
    try {
      await _getJournalEntryRef(userId, entryId).remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<JournalEntryModel>> getJournalEntriesStream(String userId) {
    return _getUserJournalRef(userId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <JournalEntryModel>[];
      }

      final value = event.snapshot.value;
      if (value is! Map) {
        return <JournalEntryModel>[];
      }

      final entriesMap = value as Map<Object?, Object?>;
      final entries = <JournalEntryModel>[];

      for (var entry in entriesMap.entries) {
        try {
          final entryData = entry.value;
          if (entryData is Map) {
            final entryJson = entryData.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            final journalEntry = JournalEntryModel.fromJson(entryJson);
            entries.add(journalEntry);
          }
        } catch (e) {
          // Skip invalid entries
        }
      }

      return entries;
    });
  }

  Future<bool> deleteAllJournalEntries(String userId) async {
    try {
      await _getUserJournalRef(userId).remove();
      return true;
    } catch (e) {
      return false;
    }
  }
}

