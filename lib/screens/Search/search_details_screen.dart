// Removed unnecessary import
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Removed unused import
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/providers/connection_Provider.dart';
// Removed unused import
import 'package:master_mind/screens/testimonial/ask_testimonial_screen.dart';
import 'package:master_mind/screens/testimonial/testimonial_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/widgets/shimmer_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
// Removed unused import

class SearchResultDetailsScreen extends StatefulWidget {
  final String userId;
  final String profilId;
  const SearchResultDetailsScreen({
    Key? key,
    required this.userId,
    required this.profilId,
  }) : super(key: key);

  @override
  State<SearchResultDetailsScreen> createState() =>
      _SearchResultDetailsScreenState();
}

class _SearchResultDetailsScreenState extends State<SearchResultDetailsScreen> {
  bool _isProfileExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConnectionProvider>(context, listen: false)
          .fetchUserDetailsUsingId(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<ConnectionProvider>(context);

    final searchResult = searchProvider.userDetails;

    if (searchProvider.isLoading) {
      return PlatformWidget.scaffold(
        context: context,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kOxygenMMPurple),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchProvider.error != null) {
      // Check if it's a "Profile not found" error
      bool isProfileNotFound =
          searchProvider.error!.toLowerCase().contains('profile not found') ||
              searchProvider.error!.toLowerCase().contains('not found');

      return PlatformWidget.scaffold(
        context: context,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kAppBarIconColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isProfileNotFound ? Icons.person_off : Icons.error_outline,
                    size: 64,
                    color: isProfileNotFound
                        ? Colors.orange[600]
                        : Colors.red[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isProfileNotFound
                      ? 'Profile Not Found'
                      : 'Error Loading Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isProfileNotFound
                        ? Colors.orange[700]
                        : Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isProfileNotFound
                      ? 'The profile you scanned doesn\'t exist or has been removed from the system.'
                      : 'Unable to load profile details. Please try again.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'User ID: ${widget.userId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kOxygenMMPurple,
                        side: BorderSide(color: kOxygenMMPurple),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Clear error and retry
                        searchProvider.clearError();
                        searchProvider.fetchUserDetailsUsingId(
                            widget.userId); // Use profileId for retry
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOxygenMMPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (searchResult == null) {
      return PlatformWidget.scaffold(
        context: context,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No profile data found.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final hasSocialLinks = (searchResult.socialMediaLinks['linkedin'] != null &&
            searchResult.socialMediaLinks['linkedin']!.isNotEmpty) ||
        (searchResult.socialMediaLinks['facebook'] != null &&
            searchResult.socialMediaLinks['facebook']!.isNotEmpty) ||
        (searchResult.socialMediaLinks['twitter'] != null &&
            searchResult.socialMediaLinks['twitter']!.isNotEmpty);

    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: kPrimaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header section with avatar and basic info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 120,
                          child: ShimmerAvatar(
                            radius: 60,
                            imageUrl: searchResult!.imageUrl,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (searchResult.name != null &&
                                  searchResult.name!.isNotEmpty)
                                Text(
                                  searchResult.name!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (searchResult.company != null &&
                                  searchResult.company!.isNotEmpty)
                                Text(
                                  searchResult.company!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // Connection button
                              ValueListenableBuilder<String?>(
                                valueListenable:
                                    Provider.of<ConnectionProvider>(context)
                                        .connectionStatusNotifier,
                                builder: (context, status, child) {
                                  if (status == 'request_received') {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimaryColor,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final connectionProvider =
                                                  Provider.of<
                                                          ConnectionProvider>(
                                                      context,
                                                      listen: false);
                                              await connectionProvider
                                                  .acceptRequest(
                                                      widget.profilId);
                                            },
                                            child: const Text(
                                              'Accept',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimaryColor,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final connectionProvider =
                                                  Provider.of<
                                                          ConnectionProvider>(
                                                      context,
                                                      listen: false);
                                              await connectionProvider
                                                  .cancelRequest(
                                                      widget.profilId);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final connectionProvider =
                                            Provider.of<ConnectionProvider>(
                                                context,
                                                listen: false);
                                        if (status == 'connected') {
                                          await connectionProvider
                                              .disconnectUser(widget.profilId);
                                        } else if (status == 'request_sent') {
                                          await connectionProvider
                                              .cancelRequest(widget.profilId);
                                        } else {
                                          await connectionProvider
                                              .sendConnectionRequest(
                                                  widget.profilId);
                                        }
                                      },
                                      child: Text(
                                        status == 'connected'
                                            ? 'Disconnect'
                                            : status == 'request_sent'
                                                ? 'Cancel Request'
                                                : 'Connect',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expandable section
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isProfileExpanded ? null : 0,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Divider
                          Container(
                            height: 1,
                            color: kPrimaryColor.withValues(alpha: 0.2),
                          ),
                          // Expanded content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Region and Chapter info
                                if (searchResult.region != null &&
                                    searchResult.region!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.location_on,
                                    label: "Region",
                                    value: searchResult.region!,
                                  ),
                                if (searchResult.chapter != null &&
                                    searchResult.chapter!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.group,
                                    label: "Chapter",
                                    value: searchResult.chapter!,
                                  ),
                                if (searchResult.memberSince != null &&
                                    searchResult.memberSince!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.calendar_today,
                                    label: "Member Since",
                                    value: searchResult.memberSince!,
                                  ),
                                if (searchResult.email != null &&
                                    searchResult.email!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.email,
                                    label: "Email",
                                    value: searchResult.email!,
                                  ),
                                if (searchResult.website != null &&
                                    searchResult.website!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.web,
                                    label: "Website",
                                    value: searchResult.website!,
                                  ),
                                if (searchResult.industries != null &&
                                    searchResult.industries!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.work_outline,
                                    label: "Industries",
                                    value: searchResult.industries!.join(', '),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expand/Collapse button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isProfileExpanded = !_isProfileExpanded;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isProfileExpanded ? 'Show Less' : 'Show More',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _isProfileExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: kPrimaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Section
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (searchResult.name != null &&
                      searchResult.name!.isNotEmpty)
                    Text(
                      "About ${searchResult.name!}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 10),
                  if (searchResult.about != null &&
                      searchResult.about!.isNotEmpty)
                    Text(
                      searchResult.about!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                    ),
                ],
              ),
            ),
            // Industries Section with Enhanced Design

            if (searchResult.industries != null &&
                searchResult.industries!.isNotEmpty)
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withValues(alpha: 0.1),
                      Colors.white
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.work, color: kPrimaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Professional Industries',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimaryColor.withValues(alpha: 0.8),
                            kGradientEndColor.withValues(alpha: 0.6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              searchResult.industries!
                                  .where((industry) => industry.isNotEmpty)
                                  .join(', '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Website section
            if (searchResult.website != null &&
                searchResult.website!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
                child: const Text(
                  "Web Address",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            if (searchResult.website != null &&
                searchResult.website!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kPrimaryColor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          searchResult.website!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Contact Details section with interactive icons
            if ((searchResult.phonenumbers != null &&
                    searchResult.phonenumbers!.isNotEmpty) ||
                (searchResult.email != null &&
                    searchResult.email!.isNotEmpty) ||
                (searchResult.googleMapLocation != null &&
                    searchResult.googleMapLocation!.isNotEmpty))
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
                child: const Text(
                  "Contact Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

            // Phone Numbers with Tappable Container
            if (searchResult.phonenumbers != null &&
                searchResult.phonenumbers!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                child: Column(
                  children: searchResult.phonenumbers!
                      .where((num) => num != null)
                      .map((num) {
                    final phoneNumber = "+91 ${num?.toString()}" ?? "-";
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _makePhoneCall(phoneNumber),
                            child: Container(
                              width: 250, // Fixed width instead of Expanded
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: kPrimaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.phone,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        phoneNumber,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Email with Tappable Container
            if (searchResult.email != null && searchResult.email!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _sendEmail(searchResult.email!),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.email,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    searchResult.email!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Location with Tappable Container
            if (searchResult.googleMapLocation != null &&
                searchResult.googleMapLocation!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _openLocation(searchResult.googleMapLocation!),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    searchResult.googleMapLocation!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35.0, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestimonialScreen(
                            userid: widget.profilId,
                            userName: searchResult?.name ?? "User",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8.0),
                    ),
                    child: const Text("Give a Testimonial"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AskTestimonialScreen(
                            userid: widget.profilId,
                            userName: searchResult?.name ?? "User",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8.0),
                    ),
                    child: const Text("Ask for Testimonial"),
                  ),
                ],
              ),
            ),
            // Enhanced Social Media Section
            if (hasSocialLinks)
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
                child: const Text(
                  "Connect on Social Media",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            if (hasSocialLinks)
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withValues(alpha: 0.1),
                      Colors.white
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.share, color: kPrimaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Social Media Profiles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (searchResult.socialMediaLinks['linkedin'] != null &&
                            searchResult
                                .socialMediaLinks['linkedin']!.isNotEmpty)
                          _buildSocialMediaButton(
                            icon: FontAwesomeIcons.linkedin,
                            label: "LinkedIn",
                            color: kPrimaryColor,
                            onTap: () => _launchSocialMedia(
                              searchResult.socialMediaLinks['linkedin']!,
                              'LinkedIn',
                            ),
                          ),
                        if (searchResult.socialMediaLinks['facebook'] != null &&
                            searchResult
                                .socialMediaLinks['facebook']!.isNotEmpty)
                          _buildSocialMediaButton(
                            icon: Icons.facebook,
                            label: "Facebook",
                            color: kPrimaryColor,
                            onTap: () => _launchSocialMedia(
                              searchResult.socialMediaLinks['facebook']!,
                              'Facebook',
                            ),
                          ),
                        if (searchResult.socialMediaLinks['twitter'] != null &&
                            searchResult
                                .socialMediaLinks['twitter']!.isNotEmpty)
                          _buildSocialMediaButton(
                            icon: FontAwesomeIcons.xTwitter,
                            label: "X",
                            color: kPrimaryColor,
                            onTap: () => _launchSocialMedia(
                              searchResult.socialMediaLinks['twitter']!,
                              'X',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> disconnectFunction() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect'),
        content: const Text('Are you sure you want to disconnect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final success = await Provider.of<ConnectionProvider>(
                  context,
                  listen: false,
                ).disconnectUser(widget.profilId);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Disconnected successfully!'
                        : 'Failed to disconnect.'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Future<void> cancelRequsetFunction(String conncetionStatus) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(conncetionStatus == 'request_sent'
            ? 'Cancel request'
            : 'Delete request'),
        content: const Text('Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final success = await Provider.of<ConnectionProvider>(
                  context,
                  listen: false,
                ).cancelRequest(widget.profilId);

                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(success
                //         ? 'Request removed successfully!'
                //         : 'Failed to remove request.'),
                //   ),
                // );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> acceptFunction() async {
    try {
      final success = await Provider.of<ConnectionProvider>(
        context,
        listen: false,
      ).acceptRequest(widget.profilId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Connection request accepted!'
              : 'Failed to accept connection request.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> sendRequestFunction() async {
    try {
      final success = await Provider.of<ConnectionProvider>(
        context,
        listen: false,
      ).sendConnectionRequest(widget.profilId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Connection request sent successfully!'
              : 'Failed to send connection request.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Contact Action Methods
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening phone app...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean phone number (remove spaces and special characters)
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      // Try to launch phone with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(phoneUri)) {
        launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(phoneUri)) {
          launched = await launchUrl(
            phoneUri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone app opened for: $cleanNumber'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Phone app not available');
      }
    } catch (e) {
      _showErrorSnackBar('Phone call failed');
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening email app...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean email address
      String cleanEmail = email.trim();

      // Create mailto URI
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: cleanEmail,
      );

      // Try to launch email with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(emailUri)) {
        launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(emailUri)) {
          launched = await launchUrl(
            emailUri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email app opened for: $cleanEmail'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Email app not available');
      }
    } catch (e) {
      _showErrorSnackBar('Email failed');
    }
  }

  Future<void> _openLocation(String location) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening maps...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean location string
      String cleanLocation = location.trim();

      // Try to open in Google Maps
      final Uri mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanLocation)}',
      );

      // Try to launch maps with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(mapsUri)) {
        launched = await launchUrl(
          mapsUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(mapsUri)) {
          launched = await launchUrl(
            mapsUri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      // If still fails, try with inAppWebView mode
      if (!launched) {
        if (await canLaunchUrl(mapsUri)) {
          launched = await launchUrl(
            mapsUri,
            mode: LaunchMode.inAppWebView,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maps opened for: $cleanLocation'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Maps not available');
      }
    } catch (e) {
      _showErrorSnackBar('Location failed');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: kPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchSocialMedia(String url, String platform) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening $platform...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean and validate URL
      String cleanUrl = url.trim();

      // Sanitize URL: Add https:// if missing
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);

      // Try to launch URL with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      // If still fails, try with inAppWebView mode
      if (!launched) {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$platform opened successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showErrorSnackBar('$platform not available');
      }
    } catch (e) {
      _showErrorSnackBar('$platform failed');
    }
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
    Key? key,
  }) : super(key: key);

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
