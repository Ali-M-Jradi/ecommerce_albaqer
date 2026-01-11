class Category {
  final int? id;
  final String name;
  final String? description;
  final int? parentId;

  Category({this.id, required this.name, this.description, this.parentId});

  // Convert Category object to Map for database insertion
  Map<String, dynamic> get categoryMap {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_id': parentId,
    };
  }

  // Create Category from Map (database result)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      parentId: map['parent_id'] as int?,
    );
  }

  // Create Category from JSON (API response)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parent_id'] as int?,
    );
  }

  // Convert Category to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_id': parentId,
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, description: $description, parentId: $parentId}';
  }
}
