class Club {
  final int id;
  final String name;
  final String description;
  final String category;
  final String? logo;
  final String instagramHandle;
  final String clubEmail;
  final int coordinator;
  final String coordinatorName;
  final String createdByName;
  final int memberCount;
  final bool isJoined;
  final String status;
  final String createdAt;
  final String updatedAt;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.logo,
    this.instagramHandle = '',
    this.clubEmail = '',
    this.coordinator = 0,
    this.coordinatorName = '',
    this.createdByName = '',
    this.memberCount = 0,
    this.isJoined = false,
    this.status = 'approved',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      logo: json['logo'],
      instagramHandle: json['instagram_handle'] ?? '',
      clubEmail: json['club_email'] ?? '',
      coordinator: json['coordinator'] ?? 0,
      coordinatorName: json['coordinator_name'] ?? '',
      createdByName: json['created_by_name'] ?? '',
      memberCount: json['member_count'] ?? 0,
      isJoined: json['is_joined'] ?? false,
      status: json['status'] ?? 'approved',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'logo': logo,
      'instagram_handle': instagramHandle,
      'club_email': clubEmail,
      'coordinator': coordinator,
      'coordinator_name': coordinatorName,
      'created_by_name': createdByName,
      'member_count': memberCount,
      'is_joined': isJoined,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}