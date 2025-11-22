import 'package:flutter/material.dart';

class SettingsModel {
  final String title;

  const SettingsModel({
    this.title = 'Settings',
  });
}

enum SettingsSection {
  account,
  notifications,
  privacy,
  preferences,
  support,
  data,
}

enum SettingsItemType {
  toggle,
  navigation,
  action,
  info,
}

class SettingsItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? icon;
  final SettingsItemType type;
  final bool? value; // For toggle items
  final VoidCallback? onTap;
  final String? route; // For navigation items

  const SettingsItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    required this.type,
    this.value,
    this.onTap,
    this.route,
  });
}

