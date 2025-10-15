import 'package:deck_note/providers/auth_provider.dart';
import 'package:deck_note/providers/todo_provider.dart';
import 'package:deck_note/screens/profile_screen.dart';
import 'package:deck_note/theme/app_theme.dart';
import 'package:deck_note/widgets/add_todo_dialog.dart';
import 'package:deck_note/widgets/todo_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'completed_todos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    print('HomeScreen: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final todoProvider = context.read<TodoProvider>();

      print('HomeScreen: User ID: ${authProvider.user?.userId}');

      if (authProvider.user != null) {
        print('HomeScreen: Starting to listen to todos');
        todoProvider.listenToTodos(authProvider.user!.userId);
        todoProvider.listenToCompletedTodos(authProvider.user!.userId);
      } else {
        print('HomeScreen: No user found!');
      }
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _refreshTodos() async {
    final authProvider = context.read<AuthProvider>();
    final todoProvider = context.read<TodoProvider>();

    if (authProvider.user != null) {
      todoProvider.listenToTodos(authProvider.user!.userId);
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final todoProvider = context.read<TodoProvider>();
    final todos = todoProvider.todos;

    if (previousIndex >= todos.length) return false;

    final todo = todos[previousIndex];

    if (direction == CardSwiperDirection.right) {
      todoProvider.completeTodo(todo.taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white),
              SizedBox(width: 10),
              Text('Task completed!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return true;
    } else if (direction == CardSwiperDirection.left) {
      // Show confirmation before deleting
      _showDeleteConfirmation(todo);
      return false; // Don't swipe yet
    }

    return false;
  }

  void _showDeleteConfirmation(todo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Delete Task',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${todo.title}"?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final todoProvider = context.read<TodoProvider>();
              await todoProvider.deleteTodo(todo.taskId);
              Navigator.of(dialogContext).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.trash, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Task deleted!'),
                    ],
                  ),
                  backgroundColor: AppTheme.accentColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshTodos,
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.surfaceColor,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Consumer<TodoProvider>(
                    builder: (context, todoProvider, child) {
                      print(
                        'HomeScreen: Building with ${todoProvider.todos.length} todos',
                      );

                      // Show error if any
                      if (todoProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.triangleExclamation,
                                size: 60,
                                color: Colors.red.withOpacity(0.7),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Error loading tasks',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  todoProvider.errorMessage!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (todoProvider.todos.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: CardSwiper(
                                controller: _swiperController,
                                cardsCount: todoProvider.todos.length,
                                numberOfCardsDisplayed:
                                    todoProvider.todos.length > 3
                                        ? 3
                                        : todoProvider.todos.length,
                                backCardOffset: const Offset(0, 50),
                                padding: const EdgeInsets.all(0),
                                scale: 0.9, // Makes back cards smaller for better visibility
                                cardBuilder:
                                    (
                                  context,
                                  index,
                                  percentThresholdX,
                                  percentThresholdY,
                                ) {
                                  print(
                                    'HomeScreen: Building card at index $index',
                                  );
                                  return TodoCard(
                                    todo: todoProvider.todos[index],
                                  );
                                },
                                onSwipe: _onSwipe,
                                allowedSwipeDirection:
                                    const AllowedSwipeDirection.only(
                                  left: true,
                                  right: true,
                                ),
                              ),
                            ),
                          ),
                          _buildSwipeInstructions(),
                          SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTodoDialog(),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const FaIcon(FontAwesomeIcons.plus, size: 20),
        label: const Text('Add Task'),
      ).animate().scale(delay: 300.ms).fadeIn(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DeckNote',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Text(
                    'Hi, ${authProvider.user?.name ?? "User"}',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              Consumer<TodoProvider>(
                builder: (context, todoProvider, child) {
                  final completedCount = todoProvider.completedTodos.length;
                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CompletedTodosScreen(),
                            ),
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.clockRotateLeft,
                          color: Colors.white,
                        ),
                      ),
                      if (completedCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              completedCount > 9 ? '9+' : '$completedCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                icon: FaIcon(FontAwesomeIcons.user, color: Colors.white),
              ),
            ],
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
            FontAwesomeIcons.clipboardList,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 20),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Tap the button below to add your first task',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(delay: 200.ms).scale(begin: Offset(0.8, 0.8)),
    );
  }

  Widget _buildSwipeInstructions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInstruction(
            FontAwesomeIcons.arrowLeft,
            'Swipe left\nto delete',
            AppTheme.accentColor,
          ),
          _buildInstruction(
            FontAwesomeIcons.arrowRight,
            'Swipe right\nto complete',
            Colors.green,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildInstruction(IconData icon, String text, Color color) {
    return Row(
      children: [
        FaIcon(icon, color: color, size: 20),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}