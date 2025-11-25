import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/connection/my_connections.dart';
import 'package:master_mind/screens/connection/recive_request.dart';
import 'package:master_mind/screens/connection/request_sent.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/shimmer_loading.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_Provider.dart';

class Connectiondetails extends StatefulWidget {
  const Connectiondetails({super.key});

  @override
  State<Connectiondetails> createState() => _ConnectiondetailsState();
}

class _ConnectiondetailsState extends State<Connectiondetails> {
  @override
  void initState() {
    super.initState();
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    connectionProvider.getAllConnectionCount();
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Colors.white;
    final Color iconColor = buttonColor;
    final Color textColor = buttonColor;
    final Color shadowColor = Colors.black12;
    final double borderRadius = 16;

    return PlatformWidget.scaffold(
      context: context,
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: buttonColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Connections',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ConnectionProvider>(
        builder: (context, provider, _) {
          return ValueListenableBuilder(
            valueListenable: provider.allconnectionsCount,
            builder: (context, allConnections, _) {
              if (provider.error != null) {
                return RefreshIndicator(
                  onRefresh: () async {
                    provider.clearError();
                    await provider.getAllConnectionCount();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${provider.error}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                provider.clearError();
                                provider.getAllConnectionCount();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Pull down to refresh',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              if (allConnections == null) {
                return ShimmerLoading.buildConnectionDetailsShimmer();
              }
              if (allConnections.data.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.getAllConnectionCount();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No connection data found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pull down to refresh',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              final data = allConnections.data[0];
              return RefreshIndicator(
                onRefresh: () async {
                  await provider.getAllConnectionCount();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        _ConnectionCard(
                          icon: Icons.people,
                          label: 'My Connections',
                          count: data.connections,
                          iconColor: iconColor,
                          textColor: textColor,
                          cardColor: cardColor,
                          shadowColor: shadowColor,
                          borderRadius: borderRadius,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyConnectionsPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _ConnectionCard(
                          icon: Icons.person_add,
                          label: 'Received Requests',
                          count: data.receiveRequests,
                          iconColor: iconColor,
                          textColor: textColor,
                          cardColor: cardColor,
                          shadowColor: shadowColor,
                          borderRadius: borderRadius,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReceivedRequestsPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _ConnectionCard(
                          icon: Icons.send,
                          label: 'Sent Requests',
                          count: data.sentRequests,
                          iconColor: iconColor,
                          textColor: textColor,
                          cardColor: cardColor,
                          shadowColor: shadowColor,
                          borderRadius: borderRadius,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SentRequestsPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;
  final Color cardColor;
  final Color shadowColor;
  final double borderRadius;

  const _ConnectionCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
    required this.iconColor,
    required this.textColor,
    required this.cardColor,
    required this.shadowColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Text(
              '($count)',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: iconColor, size: 28),
          ],
        ),
      ),
    );
  }
}
