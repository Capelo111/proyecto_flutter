import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_task_screen.dart';

class Task {
  String title;
  String description;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedTasks = prefs.getStringList('tasks');
    if (storedTasks != null) {
      setState(() {
        tasks =
            storedTasks.map((task) => Task.fromJson(jsonDecode(task))).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList =
        tasks.map((task) => jsonEncode(task.toJson())).toList();
    prefs.setStringList('tasks', taskList);
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tareas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(tasks[index].title),
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white, size: 32),
            ),
            secondaryBackground: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white, size: 32),
            ),
            onDismissed: (direction) {
              _deleteTask(index);
            },
            child: ListTile(
              title: Text(
                tasks[index].title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration:
                      tasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  color: tasks[index].isCompleted ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                tasks[index].description,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      tasks[index].isCompleted ? Colors.grey : Colors.black87,
                  decoration:
                      tasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
              ),
              trailing: GestureDetector(
                onTap: () => _toggleTaskCompletion(index),
                child: Container(
                  width: 40, // Botón más grande
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        tasks[index].isCompleted
                            ? Colors.green
                            : Colors.blueAccent, // Mejor contraste
                  ),
                  child: Icon(
                    tasks[index].isCompleted ? Icons.check : Icons.crop_square,
                    color: Colors.white,
                    size: 28, // Icono más grande
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask =
              await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddTaskScreen()),
                  )
                  as Task?;
          if (newTask != null) {
            _addTask(newTask);
          }
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }
}
