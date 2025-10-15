import 'package:deck_note/models/todo_model.dart';
import 'package:deck_note/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'edit_todo_dialog.dart';

class TodoCard extends StatelessWidget {
  final TodoModel todo;

  const TodoCard({super.key, required this.todo});

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return FontAwesomeIcons.circleExclamation;
      case Priority.medium:
        return FontAwesomeIcons.circleInfo;
      case Priority.low:
        return FontAwesomeIcons.circleMinus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = AppTheme.cardColors[todo.colorIndex];

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => EditTodoDialog(todo: todo),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.25),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 25,
          blur: 15,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor.withOpacity(0.25), cardColor.withOpacity(0.15)],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor.withOpacity(0.4), cardColor.withOpacity(0.2)],
          ),
          child: Stack(
            children: [
              // Tap hint indicator
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.penToSquare,
                    size: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              todo.priority,
                            ).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getPriorityColor(todo.priority),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                _getPriorityIcon(todo.priority),
                                size: 14,
                                color: _getPriorityColor(todo.priority),
                              ),
                              SizedBox(width: 5),
                              Text(
                                todo.priority.name.toUpperCase(),
                                style: TextStyle(
                                  color: _getPriorityColor(todo.priority),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          todo.taskId,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.5,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(color: Colors.white.withOpacity(0.2)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.clock,
                          size: 14,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Created: ${DateFormat('MMM dd, yyyy').format(todo.createdAt)}',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    if (todo.updatedAt != null) ...[
                      SizedBox(height: 5),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.penToSquare,
                            size: 14,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Updated: ${DateFormat('MMM dd, yyyy').format(todo.updatedAt!)}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.9, 0.9));
  }
}
