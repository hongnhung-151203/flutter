class Room {
  const Room({
    required this.id,
    required this.name,
    required this.status,
    required this.temperature,
    required this.price,
    this.occupant,
    this.lightOn = false,
    this.fanOn = false,
    this.gasLevel = 20,
    this.gasAlert = false,
    this.motionDetected = false,
    this.humidity = 50,
    this.fanSpeed = 50,
    this.temperatureValue = 24,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String status;
  final String temperature;
  final String price;
  final String? occupant;
  final bool lightOn;
  final bool fanOn;
  final int gasLevel;
  final bool gasAlert;
  final bool motionDetected;
  final int humidity;
  final int fanSpeed;
  final int temperatureValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOccupied => _normalizeStatus(status) == 'có_người';

  Room copyWith({
    String? id,
    String? name,
    String? status,
    String? temperature,
    String? price,
    String? occupant,
    bool? lightOn,
    bool? fanOn,
    int? gasLevel,
    bool? gasAlert,
    bool? motionDetected,
    int? humidity,
    int? fanSpeed,
    int? temperatureValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      price: price ?? this.price,
      occupant: occupant ?? this.occupant,
      lightOn: lightOn ?? this.lightOn,
      fanOn: fanOn ?? this.fanOn,
      gasLevel: gasLevel ?? this.gasLevel,
      gasAlert: gasAlert ?? this.gasAlert,
      motionDetected: motionDetected ?? this.motionDetected,
      humidity: humidity ?? this.humidity,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      temperatureValue: temperatureValue ?? this.temperatureValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'temperature': temperature,
      'price': price,
      'occupant': occupant,
      'lightOn': lightOn,
      'fanOn': fanOn,
      'gasLevel': gasLevel,
      'gasAlert': gasAlert,
      'motionDetected': motionDetected,
      'humidity': humidity,
      'fanSpeed': fanSpeed,
      'temperatureValue': temperatureValue,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Room.fromMap(String id, Map<dynamic, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
    }

    return Room(
      id: data['id']?.toString() ?? id,
      name: data['name']?.toString() ?? 'Room $id',
      status: data['status']?.toString() ?? 'Trống',
      temperature: (data['temperature']?.toString() ?? '24C').replaceAll(
        RegExp(r'[^0-9\.\-]'),
        '',
      ),
      price: data['price']?.toString() ?? '---',
      occupant: data['occupant']?.toString(),
      lightOn: data['lightOn'] == true,
      fanOn: data['fanOn'] == true,
      gasLevel: (data['gasLevel'] is num)
          ? (data['gasLevel'] as num).round()
          : 20,
      gasAlert: data['gasAlert'] == true,
      motionDetected: data['motionDetected'] == true,
      humidity: (data['humidity'] is num)
          ? (data['humidity'] as num).round()
          : 50,
      fanSpeed: (data['fanSpeed'] is num)
          ? (data['fanSpeed'] as num).round()
          : 50,
      temperatureValue: (data['temperatureValue'] is num)
          ? (data['temperatureValue'] as num).round()
          : int.tryParse(
                  (data['temperature']?.toString() ?? '24C').replaceAll(
                    RegExp(r'[^0-9\.\-]'),
                    '',
                  ),
                ) ??
                24,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  static String _normalizeStatus(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('trống')) return 'trống';
    if (lower.contains('bảo trì')) return 'bảo_trì';
    if (lower.contains('có') || lower.contains('cA') || lower.contains('ca3')) {
      return 'có_người';
    }
    return lower;
  }
}
