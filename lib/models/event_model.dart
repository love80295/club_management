class Event {
  final int id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String venue;
  final String category;
  final int club;
  final String clubName;
  final String organizerName;
  final int maxParticipants;
  final int registeredCount;
  final int availableSpots;
  final bool isFull;
  final bool isRegistered;
  final String? image;
  final bool isPast;
  final String createdAt;
  final String updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
    required this.category,
    required this.club,
    required this.clubName,
    required this.organizerName,
    required this.maxParticipants,
    this.registeredCount = 0,
    this.availableSpots = 0,
    this.isFull = false,
    this.isRegistered = false,
    this.image,
    this.isPast = false,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      venue: json['venue'] ?? '',
      category: json['category'] ?? '',
      club: json['club'] ?? 0,
      clubName: json['club_name'] ?? '',
      organizerName: json['organizer_name'] ?? '',
      maxParticipants: json['max_participants'] ?? 0,
      registeredCount: json['registered_count'] ?? 0,
      availableSpots: json['available_spots'] ?? 0,
      isFull: json['is_full'] ?? false,
      isRegistered: json['is_registered'] ?? false,
      image: json['image'],
      isPast: json['is_past'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'venue': venue,
      'category': category,
      'club': club,
      'club_name': clubName,
      'organizer_name': organizerName,
      'max_participants': maxParticipants,
      'registered_count': registeredCount,
      'available_spots': availableSpots,
      'is_full': isFull,
      'is_registered': isRegistered,
      'image': image,
      'is_past': isPast,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get formattedTime {
    if (time.isEmpty) return '';
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }
}