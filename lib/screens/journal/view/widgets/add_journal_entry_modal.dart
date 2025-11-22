import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/journal/view_model/journal_view_model.dart';

class AddJournalEntryModal extends StatefulWidget {
  final JournalEntryModel? entry;

  const AddJournalEntryModal({super.key, this.entry});

  @override
  State<AddJournalEntryModal> createState() => _AddJournalEntryModalState();
}

class _AddJournalEntryModalState extends State<AddJournalEntryModal> {
  late final TextEditingController noteController;
  late DateTime selectedDate;
  final JournalViewModel viewModel = Get.find<JournalViewModel>();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.entry?.date ?? DateTime.now();
    noteController = TextEditingController(text: widget.entry?.note ?? '');
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveEntry() {
    if (noteController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a note',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryRed,
        colorText: AppColors.white,
      );
      return;
    }
    viewModel.saveEntry(
      date: selectedDate,
      note: noteController.text.trim(),
      entryId: widget.entry?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Journal entry',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.primaryDark,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    'Date',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      height: context.responsiveButtonHeight(),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textLightPink),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: GoogleFonts.inter(
                              fontSize: context.responsiveFont(14),
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryRed,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Note
                  Text(
                    'Note',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: noteController,
                      maxLines: 5,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(14),
                        color: AppColors.primaryDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'We watched the sunset together...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: context.responsiveFont(14),
                          color: AppColors.textLightPink,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(
                          double.infinity,
                          context.responsiveButtonHeight(),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(
                          double.infinity,
                          context.responsiveButtonHeight(),
                        ),
                      ),
                      child: Text(
                        'Save Plan',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

