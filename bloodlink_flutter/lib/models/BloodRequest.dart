class BloodRequest {
  final int id;
  final int sender;
  final int receiver;
  final String patientName;
  final String bloodGroup;
  final String city;
  final String hospitalName;
  final String message;
  final String status;
  final String? donorResponse;
  final int duration;
  final String timeDuration;
  final DateTime createdAt;
  final String senderName;
  final String receiverName;
  final String? senderPhone;
  final String? senderEmail; // Added this
  final String? senderCity; // Added this
  final int minutesLeft; // Added this from server
  final bool senderAcknowledged;

  BloodRequest({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.patientName,
    required this.bloodGroup,
    required this.city,
    required this.hospitalName,
    required this.message,
    required this.status,
    this.donorResponse,
    required this.duration,
    required this.timeDuration,
    required this.createdAt,
    required this.senderName,
    required this.receiverName,
    this.senderPhone,
    this.senderEmail,
    this.senderCity,
    required this.minutesLeft,
    required this.senderAcknowledged,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['id'],
      sender: json['sender'],
      receiver: json['receiver'],
      patientName: json['patient_name'],
      bloodGroup: json['blood_group'],
      city: json['city'],
      hospitalName: json['hospital_name'],
      message: json['message'] ?? '',
      status: json['status'],
      donorResponse: json['donor_response'],
      duration: json['duration'] ?? 1,
      timeDuration: json['time_duration'] ?? '1 Hour',
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'] ?? 'Unknown',
      receiverName: json['receiver_name'] ?? 'Unknown',
      senderPhone: json['sender_phone'],
      senderEmail: json['sender_email'],
      senderCity: json['sender_city'],
      minutesLeft: json['minutes_left'] ?? 0,
      senderAcknowledged: json['sender_acknowledged'] ?? false,
    );
  }
}
