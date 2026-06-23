class SupportDetailsModel {
  final String email;
  final String phone;
  final String location;
  final String time;
  final Map<String, String> contacts;
  final int imageLimit;

  const SupportDetailsModel({
    required this.email,
    required this.phone,
    required this.location,
    required this.time,
    required this.contacts,
    this.imageLimit = 0
  });

  factory SupportDetailsModel.fromJson(Map<String, dynamic> json) {
    try {
      return SupportDetailsModel(
          email: json['email'] ?? 'Unspecified',
          phone: json['phone'] ?? 'Unspecified',
          location: json['location'] ?? 'Unspecified',
          time: json['time'] ?? 'Unspecified',
          contacts: Map<String, String>.from(json['contacts'] ?? {}),
          imageLimit: int.tryParse((json['image_limit'] ?? 0).toString()) ?? 0
      );
    } catch (er) {
      print("$json");
      return SupportDetailsModel(
          email: json['email'] ?? 'Unspecified',
          phone: json['phone'] ?? 'Unspecified',
          location: json['location'] ?? 'Unspecified',
          time: json['time'] ?? 'Unspecified',
          contacts: Map<String, String>.from(json['contacts'] ?? {}),
          imageLimit: int.tryParse(json['image_limit'] ?? 0) ?? 0
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'location': location,
      'time': time,
      'contacts': contacts,
      'image_limit': imageLimit
    };
  }
}