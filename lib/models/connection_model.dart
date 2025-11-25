class ConnectionModel {
  final bool success;
  final String message;
  final String? connectionStatus;

  const ConnectionModel({
    required this.success,
    required this.message,
    this.connectionStatus,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      connectionStatus: json['data']?['connectionStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'connectionStatus': connectionStatus,
      },
    };
  }

  @override
  String toString() {
    return 'ConnectionModel(success: $success, message: $message, connectionStatus: $connectionStatus)';
  }
}
