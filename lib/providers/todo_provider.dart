import 'package:deck_note/models/todo_model.dart';
import 'package:deck_note/services/todo_service.dart';
import 'package:flutter/material.dart';

class TodoProvider with ChangeNotifier {
  final TodoService _todoService = TodoService();

  List<TodoModel> _todos = [];
  List<TodoModel> _completedTodos = [];
  bool _isLoading = false;
  String? _error;

  List<TodoModel> get todos => _todos;
  List<TodoModel> get completedTodos => _completedTodos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToTodos(String userId) {
    _todoService.getTodosStream(userId).listen(
      (todos) {
        _todos = todos;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void listenToCompletedTodos(String userId) {
    _todoService.getCompletedTodosStream(userId).listen(
      (todos) {
        _completedTodos = todos;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createTodo({
    required String userId,
    required String title,
    required String description,
    required Priority priority,
    List<ChecklistItem>? checklist,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.createTodo(
        userId: userId,
        title: title,
        description: description,
        priority: priority,
        checklist: checklist,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTodo(TodoModel todo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.updateTodo(todo);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateChecklistItems(String taskId, List<ChecklistItem> checklist) async {
    try {
      await _todoService.updateChecklistItem(taskId, checklist);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTodo(String taskId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.completeTodo(taskId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsIncomplete(String taskId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.markAsIncomplete(taskId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTodo(String taskId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.deleteTodo(taskId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}