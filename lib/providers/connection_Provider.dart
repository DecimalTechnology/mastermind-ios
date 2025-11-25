import 'package:flutter/material.dart';
import 'package:master_mind/models/Allconnection/allCollection_model.dart';
import 'package:master_mind/models/profile_model.dart';
import 'package:master_mind/models/search_model.dart';
import 'package:master_mind/repository/connection/connectionsRepository.dart';
import 'package:master_mind/providers/base_provider.dart';

class ConnectionProvider extends BaseProvider {
  final ConnectionRepository _repository;
  final ValueNotifier<String?> _connectionStatusNotifier = ValueNotifier(null);
  final ValueNotifier<ConnectionCountModel?> _allconnectionsCount =
      ValueNotifier(null);

  ProfileModel? _userDetails;
  List<SearchResult> _requests = [];
  List<SearchResult> _connections = [];
  List<SearchResult> _sentRequests = [];
  List<SearchResult>? _allConnectionsDetails;
  List<SearchResult>? _allReceivedRequest;
  List<SearchResult>? _sentRequest;

  ConnectionProvider({required ConnectionRepository repository})
      : _repository = repository;

  // Getters
  ProfileModel? get userDetails => _userDetails;
  List<SearchResult> get requests => _requests;
  List<SearchResult> get connections => _connections;
  List<SearchResult> get sentRequests => _sentRequests;
  String? get connectionStatus => _connectionStatusNotifier.value;
  List<SearchResult>? get allconnectionsDetails => _allConnectionsDetails;
  List<SearchResult>? get allReceivedRequest => _allReceivedRequest;
  List<SearchResult>? get sentRequest => _sentRequest;
  ValueNotifier<String?> get connectionStatusNotifier =>
      _connectionStatusNotifier;
  ValueNotifier<ConnectionCountModel?> get allconnectionsCount =>
      _allconnectionsCount;

  Future<void> fetchUserDetailsUsingId(String userId) async {
    await executeAsync(
      () async {
        _userDetails = await _repository.getUserDetails(userId);
        if (_userDetails != null) {
          _connectionStatusNotifier.value = _userDetails!.conncetionStatus;
        }
        return _userDetails;
      },
      context: 'fetchUserDetailsUsingId',
    );
  }

  Future<bool> sendConnectionRequest(String userId) async {
    return await executeAsyncBool(
      () async {
        final status = await _repository.sendConnectionRequest(userId);
        _connectionStatusNotifier.value = status;
        if (status == "request_sent") {
          setSuccessMessage('Connection request sent successfully!');
          return true;
        } else {
          setError('Failed to send connection request.');
          return false;
        }
      },
      context: 'sendConnectionRequest',
    );
  }

  Future<bool> cancelRequest(String userId) async {
    return await executeAsyncBool(
      () async {
        final status = await _repository.cancelRequest(userId);
        if (status == "not_connected") {
          _connectionStatusNotifier.value = status;
          setSuccessMessage('Request cancelled successfully');
          return true;
        }
        setError('Failed to cancel request');
        return false;
      },
      context: 'cancelRequest',
    );
  }

  Future<bool> disconnectUser(String userId) async {
    return await executeAsyncBool(
      () async {
        final success = await _repository.disconnectUser(userId);
        if (success) {
          _connectionStatusNotifier.value = "not_connected";
          _connections.removeWhere((connection) => connection.id == userId);
          setSuccessMessage('User disconnected successfully');
          return true;
        }
        setError('Failed to disconnect user');
        return false;
      },
      context: 'disconnectUser',
    );
  }

  Future<bool> acceptRequest(String requestId) async {
    return await executeAsyncBool(
      () async {
        final success = await _repository.acceptRequest(requestId);
        if (success) {
          _connectionStatusNotifier.value = "connected";
          setSuccessMessage('Connection request accepted');
          return true;
        }
        setError('Failed to accept request');
        return false;
      },
      context: 'acceptRequest',
    );
  }

  Future<void> getAllConnectionCount() async {
    await executeAsync(
      () async {
        _allconnectionsCount.value =
            await _repository.getAllConnectionCount() as ConnectionCountModel?;
        return _allconnectionsCount.value;
      },
      context: 'getAllConnectionCount',
    );
  }

  Future<void> getAllConnectionDetails() async {
    await executeAsync(
      () async {
        _allConnectionsDetails = await _repository.getAllconnectionDetails();
        return _allConnectionsDetails;
      },
      context: 'getAllConnectionDetails',
    );
  }

  Future<void> getAllReceivedRequestDetails() async {
    await executeAsync(
      () async {
        _allReceivedRequest = await _repository.getAllReceivedRequestDetails();
        return _allReceivedRequest;
      },
      context: 'getAllReceivedRequestDetails',
    );
  }

  Future<void> getAllSentRequestDetails() async {
    await executeAsync(
      () async {
        _sentRequest = await _repository.getAllSentRequestDetails();
        return _sentRequest;
      },
      context: 'getAllSentRequestDetails',
    );
  }

  Future<void> ensureConnectionsLoaded() async {
    if (_allConnectionsDetails == null) {
      await getAllConnectionDetails();
    }
  }

  @override
  void dispose() {
    _connectionStatusNotifier.dispose();
    _allconnectionsCount.dispose();
    _userDetails = null;
    _requests = [];
    _connections = [];
    _sentRequests = [];
    _allConnectionsDetails = null;
    _allReceivedRequest = null;
    _sentRequest = null;
    super.dispose();
  }
}

class ConnectionSearchField extends StatefulWidget {
  final List<SearchResult> allConnections;
  final TextEditingController controller;
  final Function(String) onSelected;

  const ConnectionSearchField({
    required this.allConnections,
    required this.controller,
    required this.onSelected,
    super.key,
  });

  @override
  State<ConnectionSearchField> createState() => _ConnectionSearchFieldState();
}

class _ConnectionSearchFieldState extends State<ConnectionSearchField> {
  List<SearchResult> filteredConnections = [];
  bool showDropdown = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          controller: widget.controller,
          onChanged: (value) {
            setState(() {
              filteredConnections = widget.allConnections
                  .where((conn) => (conn.name ?? '')
                      .toLowerCase()
                      .contains(value.toLowerCase()))
                  .toList();
              showDropdown = filteredConnections.isNotEmpty && value.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            hintText: 'Thank you to:',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          ),
        ),
        if (showDropdown)
          Positioned(
            left: 0,
            right: 0,
            top: 56,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: filteredConnections.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No connections found.'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredConnections.length,
                      itemBuilder: (context, index) {
                        final conn = filteredConnections[index];
                        return ListTile(
                          leading: (conn.image != null &&
                                  conn.image!.isNotEmpty)
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(conn.image!))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(conn.name ?? ''),
                          subtitle: Text(conn.company ?? ''),
                          onTap: () {
                            widget.controller.text = conn.name ?? '';
                            widget.onSelected(conn.name ?? '');
                            setState(() {
                              showDropdown = false;
                            });
                          },
                        );
                      },
                    ),
            ),
          ),
      ],
    );
  }
}
