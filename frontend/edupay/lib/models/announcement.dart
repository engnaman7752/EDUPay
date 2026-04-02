// lib/models/announcement.dart

import 'dart:convert';

class Announcement {
  final int? id;
  final String title;
  final String content;
  final DateTime publishDate;
  final String? targetAudience;
  final int? creatorId;
  final String? creatorUsername;

  Announcement({
    this.id,
    required this.title,
    required this.content,
    required this.publishDate,
    this.targetAudience,
    this.creatorId,
    this.creatorUsername,
  });

  // Create an Announcement object from a JSON map
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      publishDate: json['publishDate'] is List
          ? DateTime(
              json['publishDate'][0],
              json['publishDate'][1],
              json['publishDate'][2],
              json['publishDate'].length > 3 ? json['publishDate'][3] : 0,
              json['publishDate'].length > 4 ? json['publishDate'][4] : 0,
              json['publishDate'].length > 5 ? json['publishDate'][5] : 0)
          : DateTime.parse(json['publishDate'].toString()),
      targetAudience: json['targetAudience'] as String?,
      creatorId: json['creatorId'] as int?,
      creatorUsername: json['creatorUsername'] as String?,
    );
  }

  // Convert an Announcement object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'publishDate': publishDate.toIso8601String(), // Send as ISO 8601 string for LocalDateTime
      'targetAudience': targetAudience,
      'creatorId': creatorId,
      'creatorUsername': creatorUsername,
    };
  }
}
