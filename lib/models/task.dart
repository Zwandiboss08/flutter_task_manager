/// The [Task] class represents a task with its attributes and provides
/// methods for converting between a Task object and a map representation.
class Task {
  final int id; // Unique identifier for the task
  final String title; // Title of the task
  final String description; // Description of the task
  final String location; // Location associated with the task
  String status; // Current status of the task (e.g., Pending, Completed)

  /// Constructor for creating a new Task instance.
  ///
  /// [id] The unique identifier for the task.
  /// [title] The title of the task.
  /// [description] The description of the task.
  /// [location] The location associated with the task.
  /// [status] The current status of the task.
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
  });

  /// Converts the Task instance to a map representation.
  ///
  /// Returns a map with the task's attributes as key-value pairs.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'status': status,
    };
  }

  /// Creates a Task instance from a map representation.
  ///
  /// [map] A map containing the task's attributes.
  /// Returns a Task instance populated with values from the map.
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'], // Retrieve the id from the map
      title: map['title'], // Retrieve the title from the map
      description: map['description'], // Retrieve the description from the map
      location: map['location'], // Retrieve the location from the map
      status: map['status'], // Retrieve the status from the map
    );
  }
}