class MechanicModel {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? skills;

  MechanicModel({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.skills,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'skills': skills,
    };
  }

  factory MechanicModel.fromMap(Map<String, dynamic> map) {
    return MechanicModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      skills: map['skills'],
    );
  }

  MechanicModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? skills,
  }) {
    return MechanicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      skills: skills ?? this.skills,
    );
  }
}
