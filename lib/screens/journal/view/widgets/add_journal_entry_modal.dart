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
  late DateTime displayedMonth;
  late final JournalViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // Find or create the ViewModel
    try {
      viewModel = Get.find<JournalViewModel>();
    } catch (e) {
      // If not found, create it
      viewModel = Get.put(JournalViewModel());
    }
    selectedDate = widget.entry?.date ?? DateTime.now();
    displayedMonth = DateTime(selectedDate.year, selectedDate.month);
    noteController = TextEditingController(text: widget.entry?.note ?? '');
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    Get.back(); // Close the calendar dialog
  }

  void _showCalendarDialog() {
    setState(() {
      displayedMonth = DateTime(selectedDate.year, selectedDate.month);
    });
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(context.responsiveSpacing(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: context.screenHeight * 0.7,
            maxWidth: context.screenWidth * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(context.responsiveSpacing(16)),
              child: _buildCalendar(),
            ),
          ),
        ),
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      selectedDate = now;
      displayedMonth = DateTime(now.year, now.month);
    });
  }

  void _clearDate() {
    setState(() {
      selectedDate = DateTime.now();
    });
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

  DateTime _getCellDate(
    int cellIndex,
    int trailingDays,
    int daysInMonth,
    DateTime previousMonth,
    int lastDayOfPreviousMonth,
  ) {
    if (cellIndex < trailingDays) {
      // Previous month
      return DateTime(
        previousMonth.year,
        previousMonth.month,
        lastDayOfPreviousMonth - trailingDays + cellIndex + 1,
      );
    } else if (cellIndex < trailingDays + daysInMonth) {
      // Current month
      return DateTime(
        displayedMonth.year,
        displayedMonth.month,
        cellIndex - trailingDays + 1,
      );
    } else {
      // Next month
      return DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
        cellIndex - trailingDays - daysInMonth + 1,
      );
    }
  }

  bool _isDateSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  bool _isDateToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildCalendarCell(DateTime cellDate) {
    final isCurrentMonth = cellDate.month == displayedMonth.month;
    final isSelected = _isDateSelected(cellDate);
    final isToday = _isDateToday(cellDate);

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectDate(cellDate),
        child: Container(
          margin: EdgeInsets.all(2),
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryRed
                : (isToday ? AppColors.backgroundPink : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppColors.primaryRed, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${cellDate.day}',
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(12),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.white
                    : (isCurrentMonth
                        ? AppColors.primaryDark
                        : AppColors.textLightPink),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _previousMonth,
          child: Icon(
            Icons.chevron_left,
            color: AppColors.primaryDark,
            size: 24,
          ),
        ),
        Text(
          '${monthNames[displayedMonth.month - 1]} ${displayedMonth.year}',
          style: GoogleFonts.inter(
            fontSize: context.responsiveFont(16),
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        GestureDetector(
          onTap: _nextMonth,
          child: Icon(
            Icons.chevron_right,
            color: AppColors.primaryDark,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDayHeaders() {
    final weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(12),
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    final previousMonth = DateTime(displayedMonth.year, displayedMonth.month - 1);
    final lastDayOfPreviousMonth = DateTime(previousMonth.year, previousMonth.month + 1, 0);
    final trailingDays = firstDayWeekday - 1;
    
    final totalCells = ((trailingDays + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: List.generate((totalCells / 7).ceil(), (weekIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (dayIndex) {
            final cellIndex = weekIndex * 7 + dayIndex;
            final cellDate = _getCellDate(
              cellIndex,
              trailingDays,
              daysInMonth,
              previousMonth,
              lastDayOfPreviousMonth.day,
            );
            return _buildCalendarCell(cellDate);
          }),
        );
      }),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(context.responsiveSpacing(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCalendarHeader(),
          SizedBox(height: context.responsiveSpacing(16)),
          _buildWeekDayHeaders(),
          SizedBox(height: context.responsiveSpacing(8)),
          _buildCalendarGrid(),
          SizedBox(height: context.responsiveSpacing(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _clearDate,
                child: Text(
                  'Clear',
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              TextButton(
                onPressed: _goToToday,
                child: Text(
                  'Today',
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final isTablet = screenWidth >= 768;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(context.responsiveSpacing(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: context.screenHeight * 0.85,
          maxWidth: isTablet ? screenWidth * 0.85 : screenWidth * 0.95,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: isTablet
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Journal Entry Form
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(context.responsiveSpacing(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Row(
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
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.primaryRed,
                                      size: context.responsiveImage(24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.responsiveSpacing(20)),

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
                            Container(
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
                                  GestureDetector(
                                    onTap: _showCalendarDialog,
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primaryRed,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.responsiveSpacing(20)),

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
                                border: Border.all(color: AppColors.textLightPink),
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
                            SizedBox(height: context.responsiveSpacing(20)),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.primaryRed),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(34),
                                      ),
                                      minimumSize: Size(
                                        double.infinity,
                                        context.responsiveButtonHeight(),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.inter(
                                        fontSize: context.responsiveFont(14),
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
                                        borderRadius: BorderRadius.circular(34),
                                      ),
                                      minimumSize: Size(
                                        double.infinity,
                                        context.responsiveButtonHeight(),
                                      ),
                                    ),
                                    child: Text(
                                      'Save Plan',
                                      style: GoogleFonts.inter(
                                        fontSize: context.responsiveFont(14),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveSpacing(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
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
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                color: AppColors.primaryRed,
                                size: context.responsiveImage(24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveSpacing(20)),

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
                      Container(
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
                            GestureDetector(
                              onTap: _showCalendarDialog,
                              child: Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryRed,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.responsiveSpacing(20)),

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
                          border: Border.all(color: AppColors.textLightPink),
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
                      SizedBox(height: context.responsiveSpacing(20)),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primaryRed),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34),
                                ),
                                minimumSize: Size(
                                  double.infinity,
                                  context.responsiveButtonHeight(),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: context.responsiveFont(14),
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
                                  borderRadius: BorderRadius.circular(34),
                                ),
                                minimumSize: Size(
                                  double.infinity,
                                  context.responsiveButtonHeight(),
                                ),
                              ),
                              child: Text(
                                'Save Plan',
                                style: GoogleFonts.inter(
                                  fontSize: context.responsiveFont(14),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

