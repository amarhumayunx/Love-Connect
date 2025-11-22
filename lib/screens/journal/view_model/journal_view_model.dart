import 'package:get/get.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/journal/model/journal_model.dart';
import 'package:uuid/uuid.dart';

import '../view/widgets/add_journal_entry_modal.dart';

class JournalViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final JournalModel model = const JournalModel();
  final RxList<JournalEntryModel> entries = <JournalEntryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  Future<void> loadEntries() async {
    isLoading.value = true;
    try {
      final loadedEntries = await _storageService.getJournalEntries();
      entries.value = loadedEntries..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to load journal entries',
      );
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
      await _storageService.saveJournalEntry(entry);
      await loadEntries();
      Get.back();
      SnackbarHelper.showSafe(
        title: entryId != null ? 'Entry Updated' : 'Entry Saved',
        message: 'Your journal entry has been saved',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save journal entry',
      );
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _storageService.deleteJournalEntry(entryId);
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

  void showAddEntryModal({JournalEntryModel? entry}) {
    Get.dialog(
      AddJournalEntryModal(entry: entry),
    );
  }
}

