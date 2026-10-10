class ParkingLocationModel {
  final int id;
  final String name;

  ParkingLocationModel({
    required this.id,
    required this.name,
  });

  factory ParkingLocationModel.fromJson(Map<String, dynamic> json) {
    return ParkingLocationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkingLocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
