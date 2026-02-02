import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';

class SupportManager {
  Future<void> contactSupport() async {
    final email = 'amarhumayun@outlook.com';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Love Connect Support Request',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: Copy email to clipboard
        await Clipboard.setData(ClipboardData(text: email));
        SnackbarHelper.showSafe(
          title: 'Email Copied',
          message: 'Email address copied to clipboard: $email',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      // Fallback: Copy email to clipboard
      await Clipboard.setData(ClipboardData(text: email));
      SnackbarHelper.showSafe(
        title: 'Email Copied',
        message: 'Email address copied to clipboard: $email',
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> rateApp() async {
    try {
      // Play Store package name
      const String packageName = 'com.loveconnect.app';

      // Try to open Play Store
      final Uri playStoreUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName',
      );

      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarHelper.showSafe(
          title: 'Unable to Open',
          message:
              'Could not open Play Store. Please search for "Love Connect" manually.',
        );
      }
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to open app store. Please try again later.',
      );
    }
  }

  Future<void> shareApp() async {
    try {
      const String packageName = 'com.loveconnect.app';
      const String playStoreLink =
          'https://play.google.com/store/apps/details?id=$packageName';
      const String shareText =
          'Check out Love Connect - the perfect app for couples!\n\n$playStoreLink';

      await Share.share(shareText, subject: 'Love Connect - App for Couples');
    } catch (e) {
      // Fallback: Copy to clipboard
      const String packageName = 'com.loveconnect.app';
      const String playStoreLink =
          'https://play.google.com/store/apps/details?id=$packageName';
      const String shareText =
          'Check out Love Connect - the perfect app for couples!\n\n$playStoreLink';

      await Clipboard.setData(ClipboardData(text: shareText));
      SnackbarHelper.showSafe(
        title: 'Link Copied',
        message: 'App link copied to clipboard!',
      );
    }
  }
}
