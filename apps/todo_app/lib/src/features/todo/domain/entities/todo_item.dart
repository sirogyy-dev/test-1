class TodoItem {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final String? categoryId;
  final String status;
  final bool completed;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.categoryId,
    required this.status,
    required this.completed,
    required this.createdAt,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? categoryId,
    String? status,
    bool? completed,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'priority': priority,
      'categoryId': categoryId,
      'status': status,
      'completed': completed,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'categoryId': categoryId,
      'status': status,
      'completed': completed,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'priority': priority,
      'categoryId': categoryId,
      'completed': completed,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    final dueDateValue = json['dueDate'];
    final createdAtValue = json['createdAt'];
    final dueDate = dueDateValue is DateTime
        ? dueDateValue
        : DateTime.tryParse(dueDateValue as String? ?? '') ?? DateTime.now();
    final createdAt = createdAtValue is DateTime
        ? createdAtValue
        : DateTime.tryParse(createdAtValue as String? ?? '') ?? DateTime.now();

    return TodoItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: dueDate,
      priority: json['priority'] as String? ?? 'Normal',
      categoryId: json['categoryId'] as String?,
      status: json['status'] as String? ?? (dueDate.isBefore(DateTime.now()) ? 'overdue' : 'pending'),
      completed: json['completed'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  factory TodoItem.fromRemoteJson(Map<String, dynamic> json, String id) {
    final dueDate = DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now();
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();

    return TodoItem(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: dueDate,
      priority: json['priority'] as String? ?? 'Normal',
      categoryId: json['categoryId'] as String?,
      status: json['status'] as String? ?? (json['completed'] as bool? ?? false
          ? 'completed'
          : (dueDate.isBefore(DateTime.now()) ? 'overdue' : 'pending')),
      completed: json['completed'] as bool? ?? false,
      createdAt: createdAt,
    );
  }
}
