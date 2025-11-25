class ConnectionCountModel {
  final bool success;
  final String message;
  final List<ConnectionCountModelData> data;

  ConnectionCountModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ConnectionCountModel.fromJson(Map<String, dynamic> json) {
    return ConnectionCountModel(
      success: json['success'],
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((item) => ConnectionCountModelData.fromJson(item))
          .toList(),
    );
  }
}

class ConnectionCountModelData {
  final int connections;
  final int sentRequests;
  final int receiveRequests;

  ConnectionCountModelData({
    required this.connections,
    required this.sentRequests,
    required this.receiveRequests,
  });

  factory ConnectionCountModelData.fromJson(Map<String, dynamic> json) {
    return ConnectionCountModelData(
      connections: json['connections'] ?? 0,
      sentRequests: json['sentRequests'] ?? 0,
      receiveRequests: json['receiveRequests'] ?? 0,
    );
  }
}
