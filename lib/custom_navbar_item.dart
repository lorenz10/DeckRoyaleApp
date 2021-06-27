import 'package:flutter/material.dart';

class CustomNavbarItem {
  final String title;
  final IconData icon;
  final Widget customWidget;

  CustomNavbarItem({
    @required this.icon,
    @required this.title,
    this.customWidget = const SizedBox(),
  });
}
