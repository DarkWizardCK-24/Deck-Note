import 'package:deck_note/models/todo_model.dart';
import 'package:deck_note/providers/todo_provider.dart';
import 'package:deck_note/theme/app_theme.dart';
import 'package:deck_note/widgets/edit_todo_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';

class CompletedTodosScreen extends StatelessWidget {
  const CompletedTodosScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, TodoModel todo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 10),
            Text('Delete Task', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${todo.title}"?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final todoProvider = context.read<TodoProvider>();
              final success = await todoProvider.deleteTodo(todo.taskId);

              Navigator.of(dialogContext).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.trash, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Task deleted permanently!'),
                      ],
                    ),
                    backgroundColor: AppTheme.accentColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, TodoModel todo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.surfaceColor, AppTheme.cardColor],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.rotateLeft,
                  color: Colors.blue,
                ),
                title: Text(
                  'Mark as Incomplete',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final todoProvider = context.read<TodoProvider>();
                  final success = await todoProvider.markAsIncomplete(
                    todo.taskId,
                  );

                  Navigator.of(bottomSheetContext).pop();

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.rotateLeft,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text('Task moved back to active tasks!'),
                          ],
                        ),
                        backgroundColor: Colors.blue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.penToSquare,
                  color: Colors.orange,
                ),
                title: Text('Edit Task', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  showDialog(
                    context: context,
                    builder: (context) => EditTodoDialog(todo: todo),
                  );
                },
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.trash,
                  color: AppTheme.accentColor,
                ),
                title: Text(
                  'Delete Task',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showDeleteConfirmation(context, todo);
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOut).fadeIn(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Consumer<TodoProvider>(
                  builder: (context, todoProvider, child) {
                    if (todoProvider.completedTodos.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: todoProvider.completedTodos.length,
                      itemBuilder: (context, index) {
                        return _buildCompletedTodoItem(
                              context,
                              todoProvider.completedTodos[index],
                            )
                            .animate()
                            .fadeIn(delay: (50 * index).ms)
                            .slideX(begin: 0.2, end: 0);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'Completed Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.circleCheck,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            'No completed tasks yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete tasks to see them here',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Widget _buildCompletedTodoItem(BuildContext context, TodoModel todo) {
    final cardColor = AppTheme.cardColors[todo.colorIndex];

    return GestureDetector(
      onTap: () => _showOptionsBottomSheet(context, todo),
      onLongPress: () => _showOptionsBottomSheet(context, todo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 180,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor.withOpacity(0.2), cardColor.withOpacity(0.1)],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor.withOpacity(0.3), cardColor.withOpacity(0.1)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        todo.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: const Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.circleCheck,
                                size: 12,
                                color: Colors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'DONE',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showOptionsBottomSheet(context, todo),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  todo.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    decoration: TextDecoration.lineThrough,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.clock,
                      size: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Completed: ${DateFormat('MMM dd, yyyy').format(todo.completedAt!)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      todo.taskId,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
