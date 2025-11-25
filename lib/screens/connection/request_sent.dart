import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/models/search_model.dart';
import 'package:master_mind/screens/Search/search_details_screen.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_Provider.dart';
import '../../widgets/shimmer_avatar.dart';
import 'package:master_mind/utils/const.dart';

class SentRequestsPage extends StatefulWidget {
  const SentRequestsPage({super.key});

  @override
  State<SentRequestsPage> createState() => _SentRequestsPageState();
}

class _SentRequestsPageState extends State<SentRequestsPage> {
  @override
  void initState() {
    super.initState();

    // Fetch received requests when the page loads
    Provider.of<ConnectionProvider>(context, listen: false)
        .getAllSentRequestDetails();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Sent Requests",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ConnectionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<SearchResult>? connections = provider.sentRequest;

          if (connections == null || connections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sent requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send connection requests to see them here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final connection = connections[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 6,
                  shadowColor: kPrimaryColor.withOpacity(0.2),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchResultDetailsScreen(
                            profilId: connection.id!,
                            userId: connection.profileId!,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPrimaryColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: ShimmerAvatar(
                                radius: 30,
                                imageUrl: connection.image,
                                child: Text(
                                  connection.name?.isNotEmpty == true
                                      ? connection.name![0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  connection.name ?? "Unknown",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  connection.company ?? "Company name",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: kPrimaryColor,
                            size: 16,
                          ),
                        ],
                      ),
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
