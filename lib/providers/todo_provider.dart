import 'package:deck_note/models/todo_model.dart';
import 'package:deck_note/services/todo_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TodoProvider extends ChangeNotifier {
  final TodoService _todoService = TodoService();
  List<TodoModel> _todos = [];
  List<TodoModel> _completedTodos = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _todosSubscription;
  StreamSubscription? _completedTodosSubscription;

  List<TodoModel> get todos => _todos;
  List<TodoModel> get completedTodos => _completedTodos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToTodos(String userId) {
    
    // Cancel existing subscription if any
    _todosSubscription?.cancel();
    
    _todosSubscription = _todoService.getTodosStream(userId).listen(
      (todos) {
        _todos = todos;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void listenToCompletedTodos(String userId) {
    
    // Cancel existing subscription if any
    _completedTodosSubscription?.cancel();
    
    _completedTodosSubscription = _todoService.getCompletedTodosStream(userId).listen(
      (todos) {
        _completedTodos = todos;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createTodo({
    required String userId,
    required String title,
    required String description,
    required Priority priority,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _todoService.createTodo(
        userId: userId,
        title: title,
        description: description,
        priority: priority,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTodo(TodoModel todo) async {
    try {
      await _todoService.updateTodo(todo);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTodo(String taskId) async {
    try {
      await _todoService.completeTodo(taskId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsIncomplete(String taskId) async {
    try {
      await _todoService.markAsIncomplete(taskId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTodo(String taskId) async {
    try {
      await _todoService.deleteTodo(taskId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _todosSubscription?.cancel();
    _completedTodosSubscription?.cancel();
    super.dispose();
  }
}