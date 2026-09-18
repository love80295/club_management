class AppUser {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? profilePic;
  final String department;
  final String year;
  final String skills;
  final String interests;
  final String role;
  final String phoneNumber;
  final bool isAdminUser;
  final bool isClubAdmin;
  final String dateJoined;
  final String createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.fullName = '',
    this.profilePic,
    this.department = '',
    this.year = '',
    this.skills = '',
    this.interests = '',
    this.role = 'student',
    this.phoneNumber = '',
    this.isAdminUser = false,
    this.isClubAdmin = false,
    this.dateJoined = '',
    this.createdAt = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? json['username'] ?? '',
      profilePic: json['profile_pic'],
      department: json['department'] ?? '',
      year: json['year'] ?? '',
      skills: json['skills'] ?? '',
      interests: json['interests'] ?? '',
      role: json['role'] ?? 'student',
      phoneNumber: json['phone_number'] ?? '',
      isAdminUser: json['is_admin_user'] ?? false,
      isClubAdmin: json['is_club_admin'] ?? false,
      dateJoined: json['date_joined'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'profile_pic': profilePic,
      'department': department,
      'year': year,
      'skills': skills,
      'interests': interests,
      'role': role,
      'phone_number': phoneNumber,
      'is_admin_user': isAdminUser,
      'is_club_admin': isClubAdmin,
      'date_joined': dateJoined,
      'created_at': createdAt,
    };
  }

  // Helper getters
  bool get isStudent => role == 'student';
  bool get isAdmin => role == 'admin' || isAdminUser;
  bool get isClubAdminRole => role == 'club_admin' || isClubAdmin;

  String get initials {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length > 1) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName[0].toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }
}