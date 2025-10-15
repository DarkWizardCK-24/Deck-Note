import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class TodoModel {
  final String taskId;
  final String userId;
  final String title;
  final String description;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final int colorIndex;

  TodoModel({
    required this.taskId,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.isCompleted = false,
    required this.colorIndex,
  });

  // Convert TodoModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'userId': userId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt), // Use Firestore Timestamp
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'isCompleted': isCompleted,
      'colorIndex': colorIndex,
    };
  }

  // Create TodoModel from Firestore Map
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    try {
      return TodoModel(
        taskId: map['taskId'] ?? '',
        userId: map['userId'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        priority: _parsePriority(map['priority']),
        createdAt: _parseTimestamp(map['createdAt']),
        updatedAt: map['updatedAt'] != null
            ? _parseTimestamp(map['updatedAt'])
            : null,
        completedAt: map['completedAt'] != null
            ? _parseTimestamp(map['completedAt'])
            : null,
        isCompleted: map['isCompleted'] ?? false,
        colorIndex: map['colorIndex'] ?? 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to parse priority
  static Priority _parsePriority(dynamic priority) {
    if (priority is String) {
      return Priority.values.firstWhere(
        (e) => e.name == priority,
        orElse: () => Priority.medium,
      );
    } else if (priority is int) {
      return Priority.values[priority];
    }
    return Priority.medium;
  }

  // Helper method to parse Timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now();
  }

  // Copy with method
  TodoModel copyWith({
    String? taskId,
    String? userId,
    String? title,
    String? description,
    Priority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool? isCompleted,
    int? colorIndex,
  }) {
    return TodoModel(
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
