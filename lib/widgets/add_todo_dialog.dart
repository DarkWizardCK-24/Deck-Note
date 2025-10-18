import 'package:deck_note/models/todo_model.dart';
import 'package:deck_note/providers/auth_provider.dart';
import 'package:deck_note/providers/todo_provider.dart';
import 'package:deck_note/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _checklistController = TextEditingController();
  Priority _selectedPriority = Priority.medium;
  final List<ChecklistItem> _checklistItems = [];
  final _uuid = Uuid();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  void _addChecklistItem() {
    if (_checklistController.text.trim().isNotEmpty) {
      setState(() {
        _checklistItems.add(
          ChecklistItem(id: _uuid.v4(), text: _checklistController.text.trim()),
        );
        _checklistController.clear();
      });
    }
  }

  void _removeChecklistItem(String id) {
    setState(() {
      _checklistItems.removeWhere((item) => item.id == id);
    });
  }

  Future<void> _handleAddTodo() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final todoProvider = context.read<TodoProvider>();

      final success = await todoProvider.createTodo(
        userId: authProvider.user!.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        checklist: _checklistItems,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white),
                SizedBox(width: 10),
                Text('Task added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 650,
        borderRadius: 25,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceColor.withOpacity(0.9),
            AppTheme.cardColor.withOpacity(0.9),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Task',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: FaIcon(
                        FontAwesomeIcons.xmark,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: FaIcon(
                              FontAwesomeIcons.heading,
                              color: Colors.white70,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _descriptionController,
                          style: TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Align(
                              alignment: Alignment.topLeft,
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  top: 16,
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.alignLeft,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Checklist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _checklistController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Add checklist item',
                                  hintStyle: TextStyle(color: Colors.white60),
                                  prefixIcon: FaIcon(
                                    FontAwesomeIcons.listCheck,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onFieldSubmitted: (_) => _addChecklistItem(),
                              ),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              onPressed: _addChecklistItem,
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.plus,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_checklistItems.isNotEmpty) ...[
                          SizedBox(height: 10),
                          Container(
                            constraints: BoxConstraints(maxHeight: 120),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _checklistItems.length,
                              itemBuilder: (context, index) {
                                final item = _checklistItems[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.circleCheck,
                                        size: 16,
                                        color: Colors.white60,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.text,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeChecklistItem(item.id),
                                        icon: FaIcon(
                                          FontAwesomeIcons.trash,
                                          size: 14,
                                          color: Colors.red.withOpacity(0.7),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        SizedBox(height: 15),
                        Text(
                          'Priority',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPriorityChip(Priority.low, Colors.green),
                            SizedBox(width: 10),
                            _buildPriorityChip(Priority.medium, Colors.orange),
                            SizedBox(width: 10),
                            _buildPriorityChip(Priority.high, Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleAddTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOut).fadeIn(),
    );
  }

  Widget _buildPriorityChip(Priority priority, Color color) {
    final isSelected = _selectedPriority == priority;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Text(
            priority.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
