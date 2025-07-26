import 'package:flutter/material.dart';

class PatientData {
  final String id;
  final String name;
  final int age;
  final String status;
  final Color statusColor;
  final String profileImage;
  final List<IssueTag> issueTags;
  final String lastVisit;

  PatientData({
    required this.id,
    required this.name,
    required this.age,
    required this.status,
    required this.statusColor,
    required this.profileImage,
    required this.issueTags,
    required this.lastVisit,
  });
}

class IssueTag {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  IssueTag(this.text, this.backgroundColor, this.textColor);
} 