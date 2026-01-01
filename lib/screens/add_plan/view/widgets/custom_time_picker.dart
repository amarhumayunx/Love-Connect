import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'dart:math' as math;

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay?) onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;
  bool _isSelectingHour = true;
  final GlobalKey _circularPickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hourOfPeriod == 0 ? 12 : widget.initialTime.hourOfPeriod;
    _selectedMinute = widget.initialTime.minute;
    _isAM = widget.initialTime.period == DayPeriod.am;
  }

  void _selectHour(int hour) {
    setState(() {
      _selectedHour = hour;
    });
  }

  void _selectMinute(int minute) {
    setState(() {
      _selectedMinute = minute;
    });
  }

  void _togglePeriod() {
    setState(() {
      _isAM = !_isAM;
    });
  }

  void _confirmSelection() {
    int hour24 = _selectedHour;
    if (_selectedHour == 12) {
      hour24 = _isAM ? 0 : 12;
    } else {
      hour24 = _isAM ? _selectedHour : _selectedHour + 12;
    }

    widget.onTimeSelected(TimeOfDay(
      hour: hour24,
      minute: _selectedMinute,
    ));
    Navigator.of(context).pop();
  }

  void _cancelSelection() {
    widget.onTimeSelected(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select time',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Digital Time Display with AM/PM
                _buildDigitalDisplay(),
                const SizedBox(height: 32),

                // Circular Time Picker
                _buildCircularPicker(),
                const SizedBox(height: 32),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _cancelSelection,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _confirmSelection,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
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

  Widget _buildDigitalDisplay() {
    final hourStr = _selectedHour.toString().padLeft(2, '0');
    final minuteStr = _selectedMinute.toString().padLeft(2, '0');

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hour
          GestureDetector(
            onTap: () => setState(() => _isSelectingHour = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isSelectingHour
                    ? AppColors.primaryRed.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSelectingHour
                      ? AppColors.primaryRed
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                hourStr,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: _isSelectingHour
                      ? AppColors.primaryRed
                      : AppColors.primaryDark.withOpacity(0.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          // Minute
          GestureDetector(
            onTap: () => setState(() => _isSelectingHour = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: !_isSelectingHour
                    ? AppColors.primaryRed.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isSelectingHour
                      ? AppColors.primaryRed
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                minuteStr,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: !_isSelectingHour
                      ? AppColors.primaryRed
                      : AppColors.primaryDark.withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // AM/PM Toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isAM = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isAM ? AppColors.primaryRed : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Text(
                      'AM',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isAM ? AppColors.white : AppColors.primaryDark.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isAM = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isAM ? AppColors.primaryRed : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: Text(
                      'PM',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: !_isAM ? AppColors.white : AppColors.primaryDark.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularPicker() {
    return Center(
      child: GestureDetector(
        onPanUpdate: _handlePanUpdate,
        onPanStart: _handlePanStart,
        onTapDown: _handleTapDown,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          key: _circularPickerKey,
          width: 280,
          height: 280,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              children: [
                _buildClockFace(),
                if (_isSelectingHour) ..._buildHourNumbers(),
                if (!_isSelectingHour) ..._buildMinuteMarkers(),
                if (_isSelectingHour) _buildHourHand(),
                if (!_isSelectingHour) _buildMinuteHand(),
                _buildCenterDot(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    _processGesture(details.globalPosition);
  }

  void _handlePanStart(DragStartDetails details) {
    _processGesture(details.globalPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _processGesture(details.globalPosition);
  }

  void _processGesture(Offset globalPosition) {
    final RenderBox? box = _circularPickerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(globalPosition);
    if (_isSelectingHour) {
      _handleHourPan(localPosition, box.size);
    } else {
      _handleMinutePan(localPosition, box.size);
    }
  }

  Widget _buildClockFace() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundPink,
      ),
    );
  }

  List<Widget> _buildHourNumbers() {
    return List.generate(12, (index) {
      final hour = index == 0 ? 12 : index;
      final angle = (index * 30 - 90) * math.pi / 180;
      final radius = 100.0;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      final isSelected = _selectedHour == hour;

      return Positioned(
        left: 140 + x - 20,
        top: 140 + y - 20,
        child: GestureDetector(
          onTap: () => _selectHour(hour),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryRed : Colors.transparent,
            ),
            child: Center(
              child: Text(
                hour.toString(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.white
                      : AppColors.primaryDark.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildMinuteMarkers() {
    return List.generate(12, (index) {
      final minute = index * 5;
      final angle = (minute * 6 - 90) * math.pi / 180;
      final radius = 100.0;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      return Positioned(
        left: 140 + x - 15,
        top: 140 + y - 15,
        child: GestureDetector(
          onTap: () => _selectMinute(minute),
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            child: Text(
              minute.toString().padLeft(2, '0'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCenterDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildHourHand() {
    final hourIndex = _selectedHour == 12 ? 0 : _selectedHour;
    final angle = (hourIndex * 30 - 90) * math.pi / 180;
    final handLength = 70.0;

    return CustomPaint(
      size: const Size(280, 280),
      painter: ClockHandPainter(
        angle: angle,
        length: handLength,
        color: AppColors.primaryRed,
        showDot: true,
      ),
    );
  }

  Widget _buildMinuteHand() {
    final minuteAngle = (_selectedMinute * 6 - 90) * math.pi / 180;
    final handLength = 85.0;

    return CustomPaint(
      size: const Size(280, 280),
      painter: ClockHandPainter(
        angle: minuteAngle,
        length: handLength,
        color: AppColors.primaryRed,
        showDot: true,
      ),
    );
  }

  void _handleHourPan(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final offset = localPosition - center;
    final angle = math.atan2(offset.dy, offset.dx);
    final degrees = (angle * 180 / math.pi + 90 + 360) % 360;

    // Convert angle to hour (1-12)
    final index = ((degrees / 30).round()) % 12;
    final hour = index == 0 ? 12 : index;

    setState(() {
      _selectedHour = hour;
    });
  }

  void _handleMinutePan(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final offset = localPosition - center;
    final angle = math.atan2(offset.dy, offset.dx);
    final degrees = (angle * 180 / math.pi + 90 + 360) % 360;

    // Convert angle to minutes and snap to 5-minute intervals
    int rawMinute = ((degrees / 6).round()) % 60;
    int minute = (rawMinute / 5).round() * 5;
    if (minute == 60) minute = 0;

    setState(() {
      _selectedMinute = minute;
    });
  }
}

class ClockHandPainter extends CustomPainter {
  final double angle;
  final double length;
  final Color color;
  final bool showDot;

  ClockHandPainter({
    required this.angle,
    required this.length,
    required this.color,
    this.showDot = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final endPoint = Offset(
      center.dx + math.cos(angle) * length,
      center.dy + math.sin(angle) * length,
    );

    // Draw line
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, endPoint, paint);

    // Draw dot at the end
    if (showDot) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endPoint, 8, dotPaint);

      // Draw white center in dot
      final whiteDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endPoint, 3, whiteDotPaint);
    }
  }

  @override
  bool shouldRepaint(ClockHandPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.length != length ||
        oldDelegate.showDot != showDot;
  }
}