import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/models/user_profile_model.dart';
import 'package:love_connect/core/services/error_handling_service.dart';
import 'package:intl/intl.dart';

/// Service for exporting data to PDF with professional template
class PdfExportService {
  /// Export complete user data to PDF
  Future<File?> exportDataToPdf({
    required List<PlanModel> plans,
    required List<JournalEntryModel> journalEntries,
    required UserProfileModel userProfile,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');

      // Generate PDF document
      final pdf = await _generatePdfDocument(
        plans: plans,
        journalEntries: journalEntries,
        userProfile: userProfile,
      );

      // Save PDF to file
      await file.writeAsBytes(await pdf.save());

      if (kDebugMode) {
        debugPrint('PDF exported to: ${file.path}');
      }

      return file;
    } catch (e, stackTrace) {
      ErrorHandlingService().handleError(
        error: e,
        stackTrace: stackTrace,
        context: 'PDF Export Service',
      );
      return null;
    }
  }

  /// Generate professional PDF document
  Future<pw.Document> _generatePdfDocument({
    required List<PlanModel> plans,
    required List<JournalEntryModel> journalEntries,
    required UserProfileModel userProfile,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final dateTimeFormat = DateFormat('dd MMMM yyyy, hh:mm a');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Separate upcoming plans from all plans
    final upcomingPlans = plans.where((plan) {
      final planDate = DateTime(plan.date.year, plan.date.month, plan.date.day);
      return planDate.isAfter(today) || planDate.isAtSameMomentAs(today);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    final pastPlans = plans.where((plan) {
      final planDate = DateTime(plan.date.year, plan.date.month, plan.date.day);
      return planDate.isBefore(today);
    }).toList()..sort((a, b) => b.date.compareTo(a.date)); // Most recent first

    // Sort journal entries by date (most recent first)
    final sortedJournals = List<JournalEntryModel>.from(journalEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Define colors
    final primaryColor = PdfColor.fromHex('#E91E63'); // Pink/Red
    final secondaryColor = PdfColor.fromHex('#F8BBD0'); // Light Pink
    final accentColor = PdfColor.fromHex('#FF6B9D'); // Accent Pink
    final textColor = PdfColors.grey800;
    final lightGrey = PdfColors.grey300;

    // Load Unicode-capable fonts to avoid Courier/Helvetica warnings
    final fonts = await _loadFonts();

    // Build PDF pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: fonts.base,
          bold: fonts.bold,
          italic: fonts.italic,
          boldItalic: fonts.boldItalic,
        ),
        build: (pw.Context context) {
          return [
            // Cover Page
            _buildCoverPage(
              userProfile: userProfile,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              accentColor: accentColor,
              dateFormat: dateFormat,
            ),

            // Table of Contents
            _buildTableOfContents(
              hasUpcomingPlans: upcomingPlans.isNotEmpty,
              hasPastPlans: pastPlans.isNotEmpty,
              hasJournals: sortedJournals.isNotEmpty,
            ),

            // User Information Page
            _buildUserInfoPage(
              userProfile: userProfile,
              primaryColor: primaryColor,
              textColor: textColor,
              dateFormat: dateFormat,
            ),

            // Upcoming Plans Section
            if (upcomingPlans.isNotEmpty)
              ..._buildPlansSection(
                plans: upcomingPlans,
                title: 'Upcoming Plans',
                subtitle: 'Your future adventures together',
                primaryColor: primaryColor,
                accentColor: accentColor,
                textColor: textColor,
                lightGrey: lightGrey,
                dateFormat: dateFormat,
                timeFormat: timeFormat,
                isUpcoming: true,
              ),

            // All Plans Section
            if (pastPlans.isNotEmpty)
              ..._buildPlansSection(
                plans: pastPlans,
                title: 'All Plans',
                subtitle: 'Memories we\'ve created together',
                primaryColor: primaryColor,
                accentColor: accentColor,
                textColor: textColor,
                lightGrey: lightGrey,
                dateFormat: dateFormat,
                timeFormat: timeFormat,
                isUpcoming: false,
              ),

            // Journal Entries Section
            if (sortedJournals.isNotEmpty)
              ..._buildJournalSection(
                journals: sortedJournals,
                primaryColor: primaryColor,
                accentColor: accentColor,
                textColor: textColor,
                lightGrey: lightGrey,
                dateFormat: dateFormat,
                dateTimeFormat: dateTimeFormat,
              ),

            // Summary Page
            _buildSummaryPage(
              totalPlans: plans.length,
              upcomingPlansCount: upcomingPlans.length,
              pastPlansCount: pastPlans.length,
              journalEntriesCount: sortedJournals.length,
              primaryColor: primaryColor,
              textColor: textColor,
              dateFormat: dateFormat,
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Build cover page
  pw.Widget _buildCoverPage({
    required UserProfileModel userProfile,
    required PdfColor primaryColor,
    required PdfColor secondaryColor,
    required PdfColor accentColor,
    required DateFormat dateFormat,
  }) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
          colors: [primaryColor, accentColor],
        ),
      ),
      padding: const pw.EdgeInsets.all(60),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(height: 80),
          pw.Text(
            'LOVE CONNECT',
            style: pw.TextStyle(
              fontSize: 42,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 3,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            width: 100,
            height: 4,
            color: PdfColors.white,
          ),
          pw.SizedBox(height: 40),
          pw.Text(
            'Digital Scrapbook',
            style: pw.TextStyle(
              fontSize: 28,
              color: PdfColors.white,
              letterSpacing: 2,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 60),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 20,
            ),
            decoration: pw.BoxDecoration(
              // Approximate 20% opacity white overlay using ARGB hex
              color: PdfColor.fromInt(0x33FFFFFF),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  userProfile.name,
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                if (userProfile.email != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    userProfile.email!,
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColor.fromInt(0xE6FFFFFF), // ~90% white
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          // Fixed height instead of flex to avoid unbounded constraints
          pw.SizedBox(height: 40),
          pw.Text(
            'Generated on ${dateFormat.format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColor.fromInt(0xCCFFFFFF), // ~80% white
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build table of contents
  pw.Widget _buildTableOfContents({
    required bool hasUpcomingPlans,
    required bool hasPastPlans,
    required bool hasJournals,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Table of Contents',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('1. User Information', style: _sectionStyle()),
          if (hasUpcomingPlans) ...[
            pw.SizedBox(height: 12),
            pw.Text('2. Upcoming Plans', style: _sectionStyle()),
          ],
          if (hasPastPlans) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              hasUpcomingPlans ? '3. All Plans' : '2. All Plans',
              style: _sectionStyle(),
            ),
          ],
          if (hasJournals) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              '${hasUpcomingPlans && hasPastPlans ? "4" : hasUpcomingPlans || hasPastPlans ? "3" : "2"}. Journal Entries',
              style: _sectionStyle(),
            ),
          ],
          pw.SizedBox(height: 12),
          pw.Text(
            '${hasUpcomingPlans && hasPastPlans && hasJournals ? "5" : (hasUpcomingPlans && hasPastPlans) || (hasUpcomingPlans && hasJournals) || (hasPastPlans && hasJournals) ? "4" : hasUpcomingPlans || hasPastPlans || hasJournals ? "3" : "2"}. Summary',
            style: _sectionStyle(),
          ),
        ],
      ),
    );
  }

  /// Build user information page
  pw.Widget _buildUserInfoPage({
    required UserProfileModel userProfile,
    required PdfColor primaryColor,
    required PdfColor textColor,
    required DateFormat dateFormat,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 15),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: primaryColor,
                  width: 3,
                ),
              ),
            ),
            child: pw.Text(
              'User Information',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Container(
            padding: const pw.EdgeInsets.all(25),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Name', userProfile.name),
                pw.SizedBox(height: 15),
                if (userProfile.email != null) ...[
                  _buildInfoRow('Email', userProfile.email!),
                  pw.SizedBox(height: 15),
                ],
                if (userProfile.about.isNotEmpty) ...[
                  _buildInfoRow('About', userProfile.about),
                  pw.SizedBox(height: 15),
                ],
                if (userProfile.gender != null) ...[
                  _buildInfoRow('Gender', userProfile.gender!),
                  pw.SizedBox(height: 15),
                ],
                _buildInfoRow(
                  'Profile Created',
                  dateFormat.format(DateTime.now()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build info row
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey800,
            ),
          ),
        ),
      ],
    );
  }

  /// Build plans section
  List<pw.Widget> _buildPlansSection({
    required List<PlanModel> plans,
    required String title,
    required String subtitle,
    required PdfColor primaryColor,
    required PdfColor accentColor,
    required PdfColor textColor,
    required PdfColor lightGrey,
    required DateFormat dateFormat,
    required DateFormat timeFormat,
    required bool isUpcoming,
  }) {
    final widgets = <pw.Widget>[];

    // Section header
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 20, bottom: 20),
        padding: const pw.EdgeInsets.all(30),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 15),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: primaryColor,
                    width: 3,
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: accentColor,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      '${plans.length} ${plans.length == 1 ? 'Plan' : 'Plans'}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );

    // Plans list
    for (int i = 0; i < plans.length; i++) {
      final plan = plans[i];
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 15),
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: lightGrey, width: 1),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 50,
                    height: 50,
                    decoration: pw.BoxDecoration(
                      // Light primary tint instead of opacity
                      color: PdfColor.fromInt(0x1AE91E63),
                      borderRadius: pw.BorderRadius.circular(25),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${i + 1}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          plan.title,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Text(
                              '📅 ',
                              style: pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              dateFormat.format(plan.date),
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                            if (plan.time != null) ...[
                              pw.SizedBox(width: 15),
                              pw.Text(
                                '🕐 ',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              pw.Text(
                                timeFormat.format(plan.time!),
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (plan.place.isNotEmpty) ...[
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Text(
                                '📍 ',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  plan.place,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: pw.BoxDecoration(
                            // Light accent tint instead of opacity
                            color: PdfColor.fromInt(0x33FF6B9D),
                            borderRadius: pw.BorderRadius.circular(15),
                          ),
                          child: pw.Text(
                            plan.type.displayName,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  /// Build journal section
  List<pw.Widget> _buildJournalSection({
    required List<JournalEntryModel> journals,
    required PdfColor primaryColor,
    required PdfColor accentColor,
    required PdfColor textColor,
    required PdfColor lightGrey,
    required DateFormat dateFormat,
    required DateFormat dateTimeFormat,
  }) {
    final widgets = <pw.Widget>[];

    // Section header
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 20, bottom: 20),
        padding: const pw.EdgeInsets.all(30),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 15),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: primaryColor,
                    width: 3,
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    'Journal Entries',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: accentColor,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      '${journals.length} ${journals.length == 1 ? 'Entry' : 'Entries'}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Your thoughts and memories',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );

    // Journal entries
    for (int i = 0; i < journals.length; i++) {
      final entry = journals[i];
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 15),
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: lightGrey, width: 1),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0x1AE91E63),
                      borderRadius: pw.BorderRadius.circular(15),
                    ),
                    child: pw.Text(
                      dateFormat.format(entry.date),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    'Entry #${journals.length - i}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                entry.note,
                style: pw.TextStyle(
                  fontSize: 13,
                  color: textColor,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  /// Build summary page
  pw.Widget _buildSummaryPage({
    required int totalPlans,
    required int upcomingPlansCount,
    required int pastPlansCount,
    required int journalEntriesCount,
    required PdfColor primaryColor,
    required PdfColor textColor,
    required DateFormat dateFormat,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 15),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: primaryColor,
                  width: 3,
                ),
              ),
            ),
            child: pw.Text(
              'Summary',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Container(
            padding: const pw.EdgeInsets.all(25),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              children: [
                _buildSummaryRow('Total Plans', totalPlans.toString()),
                pw.SizedBox(height: 15),
                _buildSummaryRow('Upcoming Plans', upcomingPlansCount.toString()),
                pw.SizedBox(height: 15),
                _buildSummaryRow('Past Plans', pastPlansCount.toString()),
                pw.SizedBox(height: 15),
                _buildSummaryRow('Journal Entries', journalEntriesCount.toString()),
              ],
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0x1AE91E63),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'Made with ❤️',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Love Connect - Digital Scrapbook',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Generated on ${dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary row
  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  /// Section text style
  pw.TextStyle _sectionStyle() {
    return pw.TextStyle(
      fontSize: 16,
      color: PdfColors.grey700,
    );
  }

  /// Load Unicode-capable fonts for the PDF
  /// Note: Using default fonts for now. To add custom Unicode fonts,
  /// download TTF/OTF files and load them using pw.Font.ttf() or pw.Font.otf()
  Future<_PdfFonts> _loadFonts() async {
    // Use default fonts - they should work for most use cases
    // The Unicode warnings are informational and won't prevent PDF generation
    return _PdfFonts(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      italic: pw.Font.helveticaOblique(),
      boldItalic: pw.Font.helveticaBoldOblique(),
    );
  }

  /// Export plans only (legacy method)
  Future<File?> exportPlansToPdf({
    required List<PlanModel> plans,
    required UserProfileModel userProfile,
    String fileName = 'love_connect_plans',
  }) async {
    return exportDataToPdf(
      plans: plans,
      journalEntries: [],
      userProfile: userProfile,
      fileName: fileName,
    );
  }

  /// Export journal entries only (legacy method)
  Future<File?> exportJournalToPdf({
    required List<JournalEntryModel> journalEntries,
    required UserProfileModel userProfile,
    String fileName = 'love_connect_journal',
  }) async {
    return exportDataToPdf(
      plans: [],
      journalEntries: journalEntries,
      userProfile: userProfile,
      fileName: fileName,
    );
  }
}

/// Holds the font set used in the PDF theme
class _PdfFonts {
  final pw.Font base;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font boldItalic;

  const _PdfFonts({
    required this.base,
    required this.bold,
    required this.italic,
    required this.boldItalic,
  });
}
