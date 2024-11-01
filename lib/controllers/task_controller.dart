import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_task_manager_app/services/database_helper.dart';
import 'package:get/get.dart';
import '../models/task.dart';

/// The [TaskController] class is a GetX controller that manages the state
/// of tasks in the application. It handles fetching, adding, updating,
/// and filtering tasks, as well as managing the map controller.
class TaskController extends GetxController {
  var tasks = <Task>[].obs; // Observable list of tasks
  var filteredTasks = <Task>[].obs; // Observable list for search filtering
  var searchQuery = ''.obs; // Observable for search query

  late MapController mapController; // Controller for managing map state
  int _nextId = 0; // Counter for generating new task IDs

  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instance of database helper

  /// Initializes the controller by fetching tasks from the database,
  /// setting up a listener for search query changes, and initializing
  /// the map controller.
  @override
  void onInit() {
    super.onInit();
    fetchTasks(); // Fetch tasks from the database on initialization
    ever(searchQuery, (callback) => filterTasks()); // Watch for changes in searchQuery
    mapController = MapController(
      initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324), // Initial map position
    );
  }

  /// Fetches tasks from the database and updates the observable task list.
  /// It also applies any filtering based on the current search query.
  Future<void> fetchTasks() async {
    tasks.value = await _dbHelper.getTasks(); // Fetch tasks from the database
    filterTasks(); // Apply filtering after fetching tasks
  }

  /// Adds a new task to the database and refreshes the task list.
  /// 
  /// [task] The task to be added.
  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task); // Insert task into the database
    fetchTasks(); // Refresh the task list
  }

  /// Updates the status of an existing task based on its ID.
  /// If the task is found, it updates the status and refreshes the task list.
  /// If the task is not found, it displays an error message using a snackbar.
  /// 
  /// [taskId] The ID of the task to be updated.
  /// [newStatus] The new status to set for the task.
  void updateTaskStatus(int taskId, String newStatus) {
    int index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      tasks[index].status = newStatus; // Update the task's status
      DatabaseHelper().updateTask(taskId, newStatus); // Update the task in the database
      tasks.refresh(); // Refresh the observable task list
    } else {
      // Show an error snackbar if the task is not found
      Get.snackbar(
        'Error',
        'Task with id $taskId not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Generates a new unique ID for a task.
  /// 
  /// Returns the next available ID.
  int generateNewId() {
    return _nextId++;
  }

  /// Filters the list of tasks based on the current search query.
  /// If the search query is empty, all tasks are shown.
  /// Otherwise, tasks are filtered by title or status.
  void filterTasks() {
    if (searchQuery.value.isEmpty) {
      filteredTasks.value = tasks; // Show all tasks if the query is empty
    } else {
      filteredTasks.value = tasks.where((task) {
        // Filter tasks based on the search query
        return task.title
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            task.status.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }
}