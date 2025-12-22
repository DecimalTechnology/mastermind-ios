import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/screens/Search/search_details_screen.dart';
// Removed unused import
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/qr_scanner_screen.dart';
import 'package:master_mind/widgets/home_drawer.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/search_provider.dart';
import 'package:master_mind/core/error_handling/handlers/global_error_handler.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/shimmer_avatar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();
  int _selectedTab = 0; // 0: Chapter Roster, 1: Worldwide Search
  bool _showMemberDetails = true;
  bool _showLocation = false;
  bool _showKeyword = false;
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // Default sort by name
  bool _isAscending = true;
  bool _isLoading = false;
  String? _errorMessage;
  final _debounceDuration = const Duration(milliseconds: 500);
  DateTime? _lastSearchTime;
  bool _showResults = false; // NEW: track if showing results
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _lastQuery = '';

  bool get _canSearch => [
        _firstNameController.text,
        _lastNameController.text,
        _companyController.text,
        _locationController.text,
        _keywordController.text,
      ].any((s) => s.trim().isNotEmpty);

  // QR Scanner Methods
  void _scanQRCode() async {
    // Navigate to QR scanner screen
    final result = await (PlatformUtils.isIOS
        ? Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const QRScannerScreen(),
            ),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScannerScreen(),
            ),
          ));

    // Handle the result
    if (result != null) {
      if (result == 'manual') {
        // Show manual entry dialog
        _showManualEntryDialog();
      } else if (result is String) {
        // User ID was scanned - navigate to profile details
        _navigateToProfileByUserId(result);
      }
    }
  }

  void _showManualEntryDialog() {
    final TextEditingController userIdController = TextEditingController();

    if (PlatformUtils.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Enter User ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: userIdController,
                  placeholder: 'Enter the user ID to view profile',
                  keyboardType: TextInputType.number,
                  padding: const EdgeInsets.all(12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter the User ID from the QR code to view that user\'s profile',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  final userId = userIdController.text.trim();
                  if (userId.isNotEmpty) {
                    Navigator.of(context).pop();
                    _navigateToProfileByUserId(userId);
                  } else {
                    // Show error on iOS
                  }
                },
                child: const Text('View Profile'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter User ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter the user ID to view profile',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the User ID from the QR code to view that user\'s profile',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final userId = userIdController.text.trim();
                  if (userId.isNotEmpty) {
                    Navigator.of(context).pop();
                    _navigateToProfileByUserId(userId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid User ID'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOxygenMMPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Profile'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToProfileByUserId(String userId) {
    // Show loading indicator
    if (PlatformUtils.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CupertinoAlertDialog(
            content: Row(
              children: [
                CupertinoActivityIndicator(),
                SizedBox(width: 16),
                Text('Loading profile...'),
              ],
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Loading profile...'),
              ],
            ),
          );
        },
      );
    }

    // Simulate API call to fetch profile by user ID
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog

      // Navigate to profile details screen
      if (PlatformUtils.isIOS) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SearchResultDetailsScreen(
              userId: userId,
              profilId: userId,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultDetailsScreen(
              userId: userId,
              profilId: userId,
            ),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeSearch();
  }

  // Removed _updateSearchButton - button state is computed from controllers
  // No need to call setState, which causes keyboard to close

  Future<void> _initializeSearch() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final searchProvider =
          Provider.of<SearchProvider>(context, listen: false);
      await searchProvider.clearResults();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize search: ${e.toString()}';
          _isLoading = false;
        });
        GlobalErrorHandler.showErrorSnackBar(context, _errorMessage!);
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    // Check if we should use cached results
    if (_lastSearchTime != null &&
        DateTime.now().difference(_lastSearchTime!) <
            const Duration(minutes: 5)) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final searchProvider =
          Provider.of<SearchProvider>(context, listen: false);
      if (_selectedTab == 0) {
        Provider.of<SearchProvider>(context, listen: false).search(
            query,
            'chapter',
            _currentPage,
            _locationController.text,
            _companyController.text);
      } else {
        Provider.of<SearchProvider>(context, listen: false).search(
            query,
            'world',
            _currentPage,
            _locationController.text,
            _companyController.text);
      }
      _lastSearchTime = DateTime.now();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Search failed: ${e.toString()}';
          _isLoading = false;
        });
        GlobalErrorHandler.showErrorSnackBar(context, _errorMessage!);
      }
    }
  }

  void _handleSort(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _isAscending = !_isAscending;
      } else {
        _sortBy = sortBy;
        _isAscending = true;
      }
    });
  }

  List<dynamic> _getSortedResults(List<dynamic> results) {
    return List.from(results)
      ..sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'name':
            comparison = (a.name ?? '').compareTo(b.name ?? '');
            break;
          case 'company':
            comparison = (a.company ?? '').compareTo(b.company ?? '');
            break;
          default:
            comparison = 0;
        }
        return _isAscending ? comparison : -comparison;
      });
  }

  void _triggerSearch(BuildContext context) async {
    _currentPage = 1; // Reset to first page for new search
    final query = [
      _firstNameController.text,
      _lastNameController.text,
      if (_showKeyword && _keywordController.text.trim().isNotEmpty)
        _keywordController.text,
    ].where((s) => s.trim().isNotEmpty).join(' ');
    _lastQuery = query; // Store the query

    // Clear old results before new search
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    await searchProvider.clearResults();

    if (_selectedTab == 0) {
      searchProvider.search(query, 'chapter', _currentPage,
          _locationController.text, _companyController.text);
    } else {
      searchProvider.search(query, 'world', _currentPage,
          _locationController.text, _companyController.text);
    }

    setState(() {
      _showResults = true;
    });
  }

  void _backToForm() {
    // Clear the search provider results when going back to form
    Provider.of<SearchProvider>(context, listen: false).clearResults();
    setState(() {
      _showResults = false;
      _currentPage = 1;
      _lastQuery = '';
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _keywordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Disable auto-leading to control it manually
        leading: _showResults
            ? PlatformUtils.isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _backToForm,
                    child: const Icon(
                      CupertinoIcons.back,
                      color: kPrimaryColor,
                      size: 28,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: kPrimaryColor,
                      size: 28,
                    ),
                    onPressed: _backToForm,
                  )
            : null,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: kOxygenMMPurple),
            onPressed: _scanQRCode,
            tooltip: 'Scan QR Code',
          ),
        ],
      ),
      drawer: _showResults ? null : MyDrawer(),
      body: _showResults
          ? _buildSearchResultsWithLoadMore(context)
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _selectedTab = 0);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTab == 0
                                  ? const Color(0xFF4B204B)
                                  : Colors.white,
                              foregroundColor: _selectedTab == 0
                                  ? Colors.white
                                  : const Color(0xFF4B204B),
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              side: const BorderSide(color: Color(0xFF4B204B)),
                            ),
                            child: const Text('Chapter search'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _selectedTab = 1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTab == 1
                                  ? const Color(0xFF4B204B)
                                  : Colors.white,
                              foregroundColor: _selectedTab == 1
                                  ? Colors.white
                                  : const Color(0xFF4B204B),
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              side: const BorderSide(color: Color(0xFF4B204B)),
                            ),
                            child: const Text('Worldwide Search'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Please enter your search criteria below.\nThe search button will be enabled when your search parameters are specific enough.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 18),
                    // Member Details
                    GestureDetector(
                      onTap: () => setState(
                          () => _showMemberDetails = !_showMemberDetails),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _showMemberDetails,
                            onChanged: (val) =>
                                setState(() => _showMemberDetails = val!),
                          ),
                          const Text('Member Details',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (_showMemberDetails)
                      Column(
                        children: [
                          TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              hintText: 'First Name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              hintText: 'Last Name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _companyController,
                            decoration: const InputDecoration(
                              hintText: 'Company',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    // Location
                    GestureDetector(
                      onTap: () => setState(() {
                        _showLocation = !_showLocation;
                        if (!_showLocation) {
                          _locationController.clear();
                        }
                      }),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _showLocation,
                            onChanged: (val) => setState(() {
                              _showLocation = val!;
                              if (!_showLocation) {
                                _locationController.clear();
                              }
                            }),
                          ),
                          const Text('Location',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (_showLocation)
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'Location',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    // Keyword
                    GestureDetector(
                      onTap: () => setState(() {
                        _showKeyword = !_showKeyword;
                        if (!_showKeyword) {
                          _keywordController.clear();
                        }
                      }),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _showKeyword,
                            onChanged: (val) => setState(() {
                              _showKeyword = val!;
                              if (!_showKeyword) {
                                _keywordController.clear();
                              }
                            }),
                          ),
                          const Text('Keyword',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (_showKeyword)
                      TextField(
                        controller: _keywordController,
                        decoration: const InputDecoration(
                          hintText: 'Keyword',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _firstNameController,
                        builder: (context, _, __) {
                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _lastNameController,
                            builder: (context, _, __) {
                              return ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _companyController,
                                builder: (context, _, __) {
                                  return ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: _locationController,
                                    builder: (context, _, __) {
                                      return ValueListenableBuilder<TextEditingValue>(
                                        valueListenable: _keywordController,
                                        builder: (context, _, __) {
                                          final canSearch = _canSearch;
                                          return ElevatedButton(
                                            onPressed: canSearch
                                                ? () => _triggerSearch(context)
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: canSearch
                                                  ? const Color(0xFF4B204B)
                                                  : Colors.grey[400],
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Search',
                                                style: TextStyle(fontSize: 16)),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(searchProvider.error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () {
                if (_selectedTab == 0) {
                  Provider.of<SearchProvider>(context, listen: false).search(
                      searchProvider.query,
                      'chapter',
                      _currentPage,
                      _locationController.text,
                      _companyController.text);
                } else {
                  Provider.of<SearchProvider>(context, listen: false).search(
                      searchProvider.query,
                      'world',
                      _currentPage,
                      _locationController.text,
                      _companyController.text);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (searchProvider.results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }
    final sortedResults = searchProvider.results;
    return ListView.separated(
      itemCount: sortedResults.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final result = sortedResults[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultDetailsScreen(
                      userId: result.profileId!,
                      profilId: result.id!,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kOxygenMMPurple.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Profile Image with Status Indicator
                    Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kOxygenMMPurple.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: ShimmerAvatar(
                              radius: 35,
                              imageUrl: result?.image ??
                                  "https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg",
                            ),
                          ),
                        ),
                        // Online Status Indicator
                        // Positioned(
                        //   bottom: 2,
                        //   right: 2,
                        //   child: Container(
                        //     width: 16,
                        //     height: 16,
                        //     decoration: BoxDecoration(
                        //       color: Colors.green,
                        //       shape: BoxShape.circle,
                        //       border: Border.all(
                        //         color: Colors.white,
                        //         width: 2,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            result.name ?? "Not mentioned",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Company Info
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: kOxygenMMPurple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.business,
                                  size: 16,
                                  color: kOxygenMMPurple,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  result.company ?? "Not mentioned",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Chapter Info
                          if (result.chapter != null &&
                              result.chapter.toString().isNotEmpty)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Chapter: ${result.chapter}',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          // Region Info
                          if (result.region != null &&
                              result.region.toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.public,
                                      size: 16,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Region: ${result.region}',
                                      style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Region Info
                          if (result.region != null &&
                              result.region.toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.public,
                                      size: 16,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Region: ${result.region}',
                                      style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 6),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color:
                                        kOxygenMMPurple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: kOxygenMMPurple.withValues(
                                          alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 14,
                                        color: kOxygenMMPurple,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'View Profile',
                                        style: TextStyle(
                                          color: kOxygenMMPurple,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      kOxygenMMPurple,
                                      kOxygenMMPurple.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultsWithLoadMore(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(searchProvider.error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () {
                if (_selectedTab == 0) {
                  Provider.of<SearchProvider>(context, listen: false).search(
                      searchProvider.query,
                      'chapter',
                      _currentPage,
                      _locationController.text,
                      _companyController.text);
                } else {
                  Provider.of<SearchProvider>(context, listen: false).search(
                      searchProvider.query,
                      'world',
                      _currentPage,
                      _locationController.text,
                      _companyController.text);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (searchProvider.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No results found.'),
            const SizedBox(height: 16),
            PlatformWidget.button(
              onPressed: _backToForm,
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              child: const Text('Back to Search'),
            ),
          ],
        ),
      );
    }
    final sortedResults = searchProvider.results;
    return ListView.separated(
      itemCount: sortedResults.length + 1, // +1 for Load More button
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        if (index < sortedResults.length) {
          final result = sortedResults[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultDetailsScreen(
                        userId: result.profileId!,
                        profilId: result.id!,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kOxygenMMPurple.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Profile Image with Status Indicator
                      Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kOxygenMMPurple.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: ShimmerAvatar(
                                radius: 35,
                                imageUrl: result?.image ??
                                    "https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg",
                              ),
                            ),
                          ),
                          // Online Status Indicator
                        ],
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              result.name ?? "Not mentioned",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Company Info
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        kOxygenMMPurple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.business,
                                    size: 16,
                                    color: kOxygenMMPurple,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    result.company ?? "Not mentioned",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: kOxygenMMPurple.withValues(
                                          alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: kOxygenMMPurple.withValues(
                                            alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.visibility,
                                          size: 14,
                                          color: kOxygenMMPurple,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'View Profile',
                                          style: TextStyle(
                                            color: kOxygenMMPurple,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        kOxygenMMPurple,
                                        kOxygenMMPurple.withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Load More Button at the end - only show if we have enough results to suggest more pages
          final searchProvider =
              Provider.of<SearchProvider>(context, listen: false);
          final resultsCount = searchProvider.results.length;

          // Only show load more button if we have at least 10 results (assuming 10 per page)
          // or if we're on page 1 and have some results
          if (resultsCount < 10 && _currentPage == 1) {
            return const SizedBox.shrink(); // Hide the button
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _isLoadingMore
                          ? null
                          : () async {
                              if (_isLoadingMore)
                                return; // Prevent multiple clicks

                              setState(() {
                                _isLoadingMore = true;
                              });

                              try {
                                // Store current results count to check if we got new results
                                final currentResultsCount =
                                    Provider.of<SearchProvider>(context,
                                            listen: false)
                                        .results
                                        .length;

                                _currentPage += 1;

                                // Perform the search with the next page
                                if (_selectedTab == 0) {
                                  await Provider.of<SearchProvider>(context,
                                          listen: false)
                                      .search(
                                    _lastQuery,
                                    'chapter',
                                    _currentPage,
                                    _locationController.text,
                                    _companyController.text,
                                  );
                                } else {
                                  await Provider.of<SearchProvider>(context,
                                          listen: false)
                                      .search(
                                    _lastQuery,
                                    'world',
                                    _currentPage,
                                    _locationController.text,
                                    _companyController.text,
                                  );
                                }

                                // Wait a moment for the provider to update
                                await Future.delayed(
                                    const Duration(milliseconds: 300));

                                // Check if we actually got new results
                                final newResultsCount =
                                    Provider.of<SearchProvider>(context,
                                            listen: false)
                                        .results
                                        .length;

                                if (newResultsCount <= currentResultsCount) {
                                  // No new results, revert page number and show message
                                  _currentPage -= 1;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('No more results available'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Error occurred, revert page number
                                _currentPage -= 1;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to load more results: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoadingMore = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Load More',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          );
        }
      },
    );
  }
}
