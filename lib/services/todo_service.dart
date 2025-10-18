import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deck_note/models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _generateTaskId() async {
    final counterDoc = _firestore.collection('counters').doc('taskId');

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterDoc);

      int newCount = 1;
      if (snapshot.exists) {
        newCount = (snapshot.data()?['count'] ?? 0) + 1;
      }

      transaction.set(counterDoc, {'count': newCount}, SetOptions(merge: true));

      return 'TASK${newCount.toString().padLeft(6, '0')}';
    });
  }

  Future<TodoModel> createTodo({
    required String userId,
    required String title,
    required String description,
    required Priority priority,
    List<ChecklistItem>? checklist,
  }) async {
    try {
      final taskId = await _generateTaskId();

      final random = Random();
      final colorIndex = random.nextInt(10);

      final todo = TodoModel(
        taskId: taskId,
        userId: userId,
        title: title,
        description: description,
        priority: priority,
        createdAt: DateTime.now(),
        colorIndex: colorIndex,
        checklist: checklist ?? [],
      );

      final todoMap = todo.toMap();

      await _firestore.collection('todos').doc(taskId).set(todoMap);

      return todo;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<TodoModel>> getTodosStream(String userId) {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final todos = <TodoModel>[];

          for (var doc in snapshot.docs) {
            try {
              final todo = TodoModel.fromMap(doc.data());
              todos.add(todo);
            } catch (e) {}
          }

          // Sort by updatedAt (for restored tasks) or createdAt, newest first
          todos.sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt;
            final bDate = b.updatedAt ?? b.createdAt;
            return bDate.compareTo(aDate);
          });

          return todos;
        });
  }

  Stream<List<TodoModel>> getCompletedTodosStream(String userId) {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final todos = <TodoModel>[];

          for (var doc in snapshot.docs) {
            try {
              final todo = TodoModel.fromMap(doc.data());
              todos.add(todo);
            } catch (e) {}
          }

          // Sort by completedAt, newest first
          todos.sort((a, b) {
            if (a.completedAt == null || b.completedAt == null) return 0;
            return b.completedAt!.compareTo(a.completedAt!);
          });

          return todos;
        });
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      final updatedTodo = todo.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('todos')
          .doc(todo.taskId)
          .update(updatedTodo.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateChecklistItem(String taskId, List<ChecklistItem> checklist) async {
    try {
      await _firestore.collection('todos').doc(taskId).update({
        'checklist': checklist.map((item) => item.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeTodo(String taskId) async {
    try {
      await _firestore.collection('todos').doc(taskId).update({
        'isCompleted': true,
        'completedAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsIncomplete(String taskId) async {
    try {
      await _firestore.collection('todos').doc(taskId).update({
        'isCompleted': false,
        'completedAt': null,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTodo(String taskId) async {
    try {
      await _firestore.collection('todos').doc(taskId).delete();
    } catch (e) {
      rethrow;
    }
  }
}