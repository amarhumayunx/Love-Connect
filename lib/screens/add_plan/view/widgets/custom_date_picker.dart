import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime?) onDateSelected;

  const CustomDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  DateTime? _tempSelectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _tempSelectedDate = _selectedDate;
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  void _selectDate(DateTime date) {
    // Normalize dates to compare only year, month, day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedFirstDate = DateTime(
      widget.firstDate.year,
      widget.firstDate.month,
      widget.firstDate.day,
    );
    final normalizedLastDate = DateTime(
      widget.lastDate.year,
      widget.lastDate.month,
      widget.lastDate.day,
    );

    if (normalizedDate.isBefore(normalizedFirstDate) ||
        normalizedDate.isAfter(normalizedLastDate)) {
      return;
    }
    setState(() {
      _tempSelectedDate = normalizedDate;
    });
    // Immediately confirm selection and close dialog
    widget.onDateSelected(normalizedDate);
    Navigator.of(context).pop();
  }

  void _clearSelection() {
    setState(() {
      _tempSelectedDate = null;
    });
    widget.onDateSelected(null);
    Navigator.of(context).pop();
  }

  void _selectToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (todayDate.isAfter(widget.firstDate.subtract(const Duration(days: 1))) &&
        todayDate.isBefore(widget.lastDate.add(const Duration(days: 1)))) {
      setState(() {
        _tempSelectedDate = todayDate;
      });
      widget.onDateSelected(todayDate);
      Navigator.of(context).pop();
    }
  }

  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;

    // Adjust to start from Monday (1 = Monday, 7 = Sunday)
    final startOffset = firstDayWeekday == 7 ? 0 : firstDayWeekday;

    List<DateTime> days = [];

    // Add previous month's trailing days
    final previousMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month - 1,
    );
    final lastDayOfPreviousMonth = DateTime(
      previousMonth.year,
      previousMonth.month + 1,
      0,
    ).day;

    for (int i = startOffset - 1; i >= 0; i--) {
      days.add(
        DateTime(
          previousMonth.year,
          previousMonth.month,
          lastDayOfPreviousMonth - i,
        ),
      );
    }

    // Add current month's days
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_displayedMonth.year, _displayedMonth.month, day));
    }

    // Fill remaining cells to complete the grid (6 rows x 7 columns = 42 cells)
    final remainingDays = 42 - days.length;
    if (remainingDays > 0) {
      for (int day = 1; day <= remainingDays; day++) {
        days.add(
          DateTime(_displayedMonth.year, _displayedMonth.month + 1, day),
        );
      }
    }

    return days;
  }

  bool _isCurrentMonth(DateTime date) {
    return date.year == _displayedMonth.year &&
        date.month == _displayedMonth.month;
  }

  bool _isSelected(DateTime date) {
    if (_tempSelectedDate == null) return false;
    return date.year == _tempSelectedDate!.year &&
        date.month == _tempSelectedDate!.month &&
        date.day == _tempSelectedDate!.day;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _getMonthYearText() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_displayedMonth.month - 1]} ${_displayedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(
            0xFFFAFAFA,
          ), // Very light gray/off-white background
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with month/year and navigation arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _previousMonth,
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColors.primaryRed,
                    size: 24,
                  ),
                ),
                Text(
                  _getMonthYearText(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryRed,
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryRed,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Day labels row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayLabels.map((label) {
                return Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final date = days[index];
                final isCurrentMonth = _isCurrentMonth(date);
                final isSelected = _isSelected(date);
                // Normalize dates for comparison
                final normalizedDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                );
                final normalizedFirstDate = DateTime(
                  widget.firstDate.year,
                  widget.firstDate.month,
                  widget.firstDate.day,
                );
                final normalizedLastDate = DateTime(
                  widget.lastDate.year,
                  widget.lastDate.month,
                  widget.lastDate.day,
                );
                final isDisabled =
                    normalizedDate.isBefore(normalizedFirstDate) ||
                    normalizedDate.isAfter(normalizedLastDate);

                return GestureDetector(
                  onTap: isDisabled ? null : () => _selectDate(date),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isDisabled
                            ? Colors.grey.shade300
                            : isCurrentMonth
                            ? AppColors.primaryRed
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Footer with Clear and Today buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _clearSelection,
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _selectToday,
                  child: Text(
                    'Today',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
