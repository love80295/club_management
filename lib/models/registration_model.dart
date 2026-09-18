class Registration {
  final String id;
  final int user;
  final String userName;
  final int event;
  final String eventTitle;
  final String eventDate;
  final String eventTime;
  final String eventVenue;
  final String status;
  final String registeredAt;
  final String updatedAt;
  final bool isCheckedIn;
  final String? checkedInAt;
  final String qrCode;

  Registration({
    required this.id,
    required this.user,
    this.userName = '',
    required this.event,
    this.eventTitle = '',
    this.eventDate = '',
    this.eventTime = '',
    this.eventVenue = '',
    this.status = 'Pending',
    this.registeredAt = '',
    this.updatedAt = '',
    this.isCheckedIn = false,
    this.checkedInAt,
    this.qrCode = '',
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      id: json['id']?.toString() ?? '',
      user: json['user'] ?? 0,
      userName: json['user_name'] ?? '',
      event: json['event'] ?? 0,
      eventTitle: json['event_title'] ?? '',
      eventDate: json['event_date'] ?? '',
      eventTime: json['event_time'] ?? '',
      eventVenue: json['event_venue'] ?? '',
      status: json['status'] ?? 'Pending',
      registeredAt: json['registered_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isCheckedIn: json['is_checked_in'] ?? false,
      checkedInAt: json['checked_in_at'],
      qrCode: json['qr_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'user_name': userName,
      'event': event,
      'event_title': eventTitle,
      'event_date': eventDate,
      'event_time': eventTime,
      'event_venue': eventVenue,
      'status': status,
      'registered_at': registeredAt,
      'updated_at': updatedAt,
      'is_checked_in': isCheckedIn,
      'checked_in_at': checkedInAt,
      'qr_code': qrCode,
    };
  }
}