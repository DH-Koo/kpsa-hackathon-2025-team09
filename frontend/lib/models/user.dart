class User {
  final int id;
  final String email;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? birth;
  final String? job;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.birth,
    this.job,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      birth: json['birth'] != null ? DateTime.parse(json['birth']) : null,
      job: json['job'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'birth': birth?.toIso8601String(),
      'job': job,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? birth,
    String? job,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      birth: birth ?? this.birth,
      job: job ?? this.job,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
