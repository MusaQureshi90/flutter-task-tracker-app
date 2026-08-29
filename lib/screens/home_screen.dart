import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/storage_helper.dart';
import '../widgets/task_tile.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskController = TextEditingController();

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _taskController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g., Review PR on GitHub',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) {
                  Provider.of<TaskProvider>(context, listen: false).addTask(_taskController.text);
                  _taskController.clear();
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false).addTask(_taskController.text);
                  _taskController.clear();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Task'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await StorageHelper.clearLoginState();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          onLogin: () async {
            await StorageHelper.saveLoginState(true);
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(toggleTheme: widget.toggleTheme),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks & Priorities', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6_outlined),
                onPressed: widget.toggleTheme,
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: _logout,
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist_rounded, size: 70, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('All caught up!', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          const Text('Tap + button below to create your first task.'),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pending (${provider.pendingCount})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (provider.completedCount > 0)
                                TextButton(
                                  onPressed: provider.clearCompletedTasks,
                                  child: const Text('Clear Completed', style: TextStyle(color: Colors.redAccent)),
                                ),
                            ],
                          ),
                        ),
                        ...provider.tasks.map((task) => TaskTile(task: task)),
                      ],
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTaskSheet(context),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Task'),
          ),
        );
      },
    );
  }
}