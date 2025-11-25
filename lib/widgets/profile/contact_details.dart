import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:master_mind/utils/const.dart';

class ContactDetails extends StatelessWidget {
  final dynamic profile;

  const ContactDetails({
    super.key,
    required this.profile,
  });

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    try {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone app opened for: $cleanNumber'),
            backgroundColor: kPrimaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackBar(context, 'Phone app not available');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Phone call failed');
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    try {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email app opened for: $cleanEmail'),
            backgroundColor: kPrimaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackBar(context, 'Email app not available');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Email failed');
    }
  }

  Future<void> _openLocation(BuildContext context, String location) async {
    try {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maps opened for: $cleanLocation'),
            backgroundColor: kPrimaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackBar(context, 'Maps not available');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Location failed');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kPrimaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Website section
        if (profile?.website != null &&
            (profile!.website?.isNotEmpty ?? false)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
            child: Text(
              "Web Address",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kPrimaryColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
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
                      profile!.website ?? "",
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
        ],

        // Contact Details section
        if ((profile?.phonenumbers != null &&
                profile!.phonenumbers!.isNotEmpty) ||
            (profile?.email != null && profile!.email!.isNotEmpty) ||
            (profile?.googleMapLocation != null &&
                profile!.googleMapLocation!.isNotEmpty)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
            child: Text(
              "Contact Details",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kPrimaryColor),
            ),
          ),

          // Phone Numbers with Call Icons
          if (profile?.phonenumbers != null &&
              profile!.phonenumbers!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
              child: Column(
                children: profile!.phonenumbers!.map((num) {
                  final phoneNumber = "+91 ${num?.toString()}" ?? "-";
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kPrimaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _makePhoneCall(context, phoneNumber),
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kOxygenMMPurple,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Email with Mail Icon
          if (profile?.email != null && profile!.email!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPrimaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.email, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                profile!.email ?? "",
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
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendEmail(context, profile!.email!),
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPrimaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Location with Map Icon
          if (profile?.googleMapLocation != null &&
              profile!.googleMapLocation!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPrimaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                profile!.googleMapLocation ?? "",
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
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        _openLocation(context, profile!.googleMapLocation!),
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPrimaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
