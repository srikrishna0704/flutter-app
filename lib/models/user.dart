class Address {
  final String id;
  final String fullName;
  final String address;
  final String city;
  final String pincode;
  final String state;
  final String phone;

  Address({
    required this.id,
    required this.fullName,
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    required this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      state: json['state'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'address': address,
      'city': city,
      'pincode': pincode,
      'state': state,
      'phone': phone,
    };
  }

  String get fullDisplayAddress => '$address, $city';
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['displayName'] ?? 'User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (token != null) 'token': token,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? token,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token,
    );
  }
}

