import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_task_manager_app/models/task.dart';
import 'package:flutter_task_manager_app/views/map_selection_page_view.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_list.dart';

/// The [TaskView] class is a stateless widget that provides the main
/// interface for managing tasks. It allows users to add new tasks,
/// view existing tasks, and search for tasks.
class TaskView extends StatelessWidget {
  final TaskController controller = Get.put(TaskController()); // Get the TaskController instance
  final TextEditingController titleController = TextEditingController(); // Controller for task title input
  final TextEditingController descriptionController = TextEditingController(); // Controller for task description input
  final TextEditingController locationController = TextEditingController(); // Controller for task location input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'), // App bar title
        actions: [
          IconButton(
            icon: const Icon(Icons.search), // Search icon
            onPressed: () {
              showSearch(context: context, delegate: TaskSearch(controller)); // Show search delegate
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController, // Title input field
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController, // Description input field
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: locationController, // Location input field
              decoration: const InputDecoration(labelText: 'Location'),
              readOnly: true, // Makes it non-editable
              onTap: () async {
                // Show the map directly on tap to select a location
                GeoPoint? selectedPoint = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MapSelectionPage(), // Navigate to map selection page
                  ),
                );
                if (selectedPoint != null) {
                  // Convert the selected GeoPoint to an address
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                    selectedPoint.latitude,
                    selectedPoint.longitude,
                  );
                  if (placemarks.isNotEmpty) {
                    // Set the first address found to the location field
                    locationController.text =
                        '${placemarks.first.street}, ${placemarks.first.subLocality}';
                  }
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add the new task using the controller
                controller.addTask(Task(
                  id: controller.generateNewId(), // Generate a new ID
                  title: titleController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  status: 'Pending', // Default status
                ));
                // Clear the text fields after adding the task
                titleController.clear();
                descriptionController.clear();
                locationController.clear();
              },
              child: const Text('Add Task'), // Button to add task
            ),
            Expanded(child: TaskList()), // Display the list of tasks
          ],
        ),
      ),
    );
  }
}

/// The [TaskSearch] class is a search delegate that provides the
/// functionality for searching tasks within the TaskView.
class TaskSearch extends SearchDelegate {
  final TaskController controller; // Reference to the TaskController

  TaskSearch(this.controller); // Constructor to initialize the controller

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear), // Clear icon
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back), // Back icon
      onPressed: () {
        close(context, null); // Close the search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    controller.searchQuery.value =
        query; // Update the search query in the controller
    return Obx(() {
      final results = controller.filteredTasks; // Get the filtered tasks
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(results[index].title ),
            subtitle: Text(results[index].status),
            onTap: () {
              close(context,
                  results[index]); // Close search and return selected task
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Obx(() {
      final suggestions =
          controller.filteredTasks; // Get suggestions based on current query
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestions[index].title),
            subtitle: Text(suggestions[index].status),
          );
        },
      );
    });
  }
}