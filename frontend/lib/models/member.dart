class Member {
  final int? id;
  final String fullName;
  final String email;

  Member({this.id, required this.fullName, required this.email});

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as int?,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
      );

  // id is not sent: the backend generates it
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
      };

  @override
  bool operator ==(Object other) => other is Member && other.id == id;

  @override
  int get hashCode => id.hashCode;
}