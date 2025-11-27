import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/models/search_model.dart';
import 'package:master_mind/screens/Search/search_details_screen.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_Provider.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/shimmer_avatar.dart';
import 'package:master_mind/widgets/shimmer_loading.dart';

class MyConnectionsPage extends StatefulWidget {
  const MyConnectionsPage({super.key});

  @override
  State<MyConnectionsPage> createState() => _MyConnectionsPageState();
}

class _MyConnectionsPageState extends State<MyConnectionsPage> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _filteredConnections = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    await provider.getAllConnectionDetails();
  }

  Future<void> _refreshConnections() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadConnections();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _filterConnections(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _filteredConnections = [];
        _isSearching = false;
      });
      return;
    }

    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    final connections = provider.allconnectionsDetails ?? [];

    setState(() {
      _filteredConnections = connections.where((connection) {
        final name = connection.name?.toLowerCase() ?? '';
        final company = connection.company?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || company.contains(searchQuery);
      }).toList();
    });
  }

  List<SearchResult> _getDisplayConnections() {
    if (_isSearching) {
      return _filteredConnections;
    }
    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    return provider.allconnectionsDetails ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child:
              const Icon(CupertinoIcons.back, color: kPrimaryColor, size: 28),
        ),
        title: const Text(
          "My Connections",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshConnections,
          ),
        ],
      ),
      body: Consumer<ConnectionProvider>(
        builder: (context, provider, _) {
          // Show loading indicator
          if (provider.isLoading && !_isRefreshing) {
            return ShimmerLoading.buildConnectionsListShimmer();
          }

          // Show error state
          if (provider.error != null) {
            return RefreshIndicator(
              onRefresh: () async {
                await _loadConnections();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading connections',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadConnections,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
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

          final connections = _getDisplayConnections();

          // Show empty state
          if (connections.isEmpty) {
            return Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterConnections,
                    decoration: InputDecoration(
                      hintText: 'Search connections...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterConnections('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: kPrimaryColor.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: kPrimaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                // Empty State
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSearching
                              ? Icons.search_off
                              : Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching
                              ? 'No matching connections'
                              : 'No connections yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSearching
                              ? 'Try adjusting your search terms'
                              : 'Start connecting with people to see them here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        if (!_isSearching) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Find Connections'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Show connections list with search
          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterConnections,
                  decoration: InputDecoration(
                    hintText: 'Search connections...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterConnections('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: kPrimaryColor.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              // Search Results Count
              if (_isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${connections.length} result${connections.length == 1 ? '' : 's'} found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterConnections('');
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Connections List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshConnections,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: connections.length,
                    itemBuilder: (context, index) {
                      final connection = connections[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 6,
                          shadowColor: kPrimaryColor.withValues(alpha: 0.2),
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
                                  builder: (context) =>
                                      SearchResultDetailsScreen(
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
                                        color: kPrimaryColor.withValues(
                                            alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: ShimmerAvatar(
                                        radius: 30,
                                        imageUrl: connection.image,
                                        child: Text(
                                          connection.name?.isNotEmpty == true
                                              ? connection.name![0]
                                                  .toUpperCase()
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Clear any error messages when leaving the page
    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    provider.clearMessages();
    super.dispose();
  }
}
