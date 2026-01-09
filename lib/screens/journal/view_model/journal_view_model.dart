import 'package:get/get.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/journal_database_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/journal/model/journal_model.dart';
import 'package:uuid/uuid.dart';

import '../view/widgets/add_journal_entry_modal.dart';

class JournalViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final JournalDatabaseService _journalDbService = JournalDatabaseService();
  final AuthService _authService = AuthService();
  final JournalModel model = const JournalModel();
  final RxList<JournalEntryModel> entries = <JournalEntryModel>[].obs;
  final RxList<JournalEntryModel> filteredEntries = <JournalEntryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filteredEntries.value = [];
    loadEntries();
  }

  Future<void> loadEntries() async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      List<JournalEntryModel> loadedEntries = [];

      // CRITICAL: Only load entries if user is authenticated
      if (userId != null) {
        try {
          loadedEntries = await _journalDbService.getJournalEntries(userId);
          // If Firebase returned entries, use them
          if (loadedEntries.isNotEmpty) {
            // Sort by date, newest first
            loadedEntries.sort((a, b) => b.date.compareTo(a.date));
            entries.value = loadedEntries;
            
            // Sync to user-specific local storage
            for (var entry in loadedEntries) {
              await _storageService.saveJournalEntry(entry, userId: userId);
            }
            _applySearchFilter();
            return;
          }
        } catch (e) {
          print('Failed to load journal entries from Firebase: $e');
          // Continue to try user-specific local storage as fallback
        }

        // If no entries from Firebase, check user-specific local storage
        final localEntries = await _storageService.getJournalEntries(userId: userId);
        if (localEntries.isNotEmpty) {
          loadedEntries = localEntries;
        }
      } else {
        // No user authenticated - show empty entries
        loadedEntries = [];
      }

      // Sort by date, newest first
      loadedEntries.sort((a, b) => b.date.compareTo(a.date));
      entries.value = loadedEntries;
      _applySearchFilter();
    } catch (e) {
      print('Error loading journal entries: $e');
      entries.value = [];
      _applySearchFilter();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveEntry({
    required DateTime date,
    required String note,
    String? entryId,
  }) async {
    try {
      final entry = JournalEntryModel(
        id: entryId ?? const Uuid().v4(),
        date: date,
        note: note,
      );
      
      final userId = _authService.currentUserId;

      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Please login to save journal entries',
        );
        return;
      }

      // Save to local storage first
      final savedLocally = await _saveToLocalStorage(entry, userId);
      
      // Initiate background save to Firebase
      _initiateBackgroundSave(entry, userId);

      if (savedLocally) {
        await loadEntries();
        Get.back();
        SnackbarHelper.showSafe(
          title: entryId != null ? 'Entry Updated' : 'Entry Saved',
          message: 'Your journal entry has been saved. Syncing to cloud...',
          duration: const Duration(seconds: 2),
        );
      } else {
        // If local save failed, try Firebase directly
        await _handleLocalSaveFailure(entry, userId, entryId);
      }
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save journal entry',
      );
    }
  }

  Future<bool> _saveToLocalStorage(JournalEntryModel entry, String userId) async {
    try {
      await _storageService.saveJournalEntry(entry, userId: userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _initiateBackgroundSave(JournalEntryModel entry, String userId) {
    _journalDbService.saveJournalEntry(userId: userId, entry: entry).catchError((_) {
      // Background save errors are handled silently
      return false;
    });
  }

  Future<void> _handleLocalSaveFailure(
    JournalEntryModel entry,
    String userId,
    String? entryId,
  ) async {
    try {
      final savedToFirebase = await _journalDbService.saveJournalEntry(
        userId: userId,
        entry: entry,
      );
      if (savedToFirebase) {
        await loadEntries();
        Get.back();
        SnackbarHelper.showSafe(
          title: entryId != null ? 'Entry Updated' : 'Entry Saved',
          message: 'Your journal entry has been saved successfully',
        );
      } else {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Failed to save journal entry. Please check your connection and try again.',
        );
      }
    } catch (_) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save journal entry. Please check your connection and try again.',
      );
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      final userId = _authService.currentUserId;

      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Please login to delete journal entries',
        );
        return;
      }

      // Delete from local storage
      await _storageService.deleteJournalEntry(entryId, userId: userId);
      
      // Delete from Firebase in background
      _journalDbService.deleteJournalEntry(
        userId: userId,
        entryId: entryId,
      ).catchError((_) {
        // Background delete errors are handled silently
        return false;
      });

      await loadEntries();
      SnackbarHelper.showSafe(
        title: 'Entry Deleted',
        message: 'Journal entry has been deleted',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to delete journal entry',
      );
    }
  }

  Future<void> refreshEntries() async {
    isRefreshing.value = true;
    try {
      await loadEntries();
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to refresh entries',
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applySearchFilter();
  }

  void _applySearchFilter() {
    try {
      if (searchQuery.value.isEmpty) {
        filteredEntries.value = List.from(entries);
        return;
      }

      final query = searchQuery.value.toLowerCase();
      filteredEntries.value = entries.where((entry) {
        return entry.note.toLowerCase().contains(query);
      }).toList();
    } catch (e) {
      // If filtering fails, show all entries
      filteredEntries.value = List.from(entries);
    }
  }

  void showAddEntryModal({JournalEntryModel? entry}) {
    Get.dialog(
      AddJournalEntryModal(entry: entry),
    );
  }
}

