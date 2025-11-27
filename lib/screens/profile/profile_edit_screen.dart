import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/models/profile_model.dart';
import 'package:master_mind/providers/profile_provider.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/core/error_handling/handlers/global_error_handler.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _regionController;
  late TextEditingController _memberSinceController;
  late TextEditingController _aboutController;
  List<TextEditingController> _phoneControllers = [];
  late TextEditingController _websiteController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _linkedInController;
  late TextEditingController _facebookController;
  late TextEditingController _twitterController;
  late TextEditingController _dobController;
  late TextEditingController _chapterController;

  List<String> selectedIndustries = [];
  final List<String> availableIndustries = [
    'Telecom',
    'Construction',
    'Marketing',
    'Technology',
    'Finance',
    'Healthcare'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    try {
      final profile =
          Provider.of<ProfileProvider>(context, listen: false).profile;

      _nameController = TextEditingController(text: profile?.name ?? '');
      _companyController = TextEditingController(text: profile?.company ?? '');
      _regionController = TextEditingController(text: profile?.region ?? '');
      _memberSinceController =
          TextEditingController(text: profile?.memberSince ?? '');
      _aboutController = TextEditingController(text: profile?.about ?? '');
      _phoneControllers = [];
      if (profile?.phonenumbers != null && profile!.phonenumbers.isNotEmpty) {
        for (final num in profile.phonenumbers) {
          _phoneControllers.add(TextEditingController(text: num.toString()));
        }
      } else {
        _phoneControllers.add(TextEditingController());
      }
      _websiteController = TextEditingController(text: profile?.website ?? '');
      _emailController = TextEditingController(text: profile?.email ?? '');
      _locationController =
          TextEditingController(text: profile?.googleMapLocation ?? '');
      _linkedInController = TextEditingController(
        text: _getSocialLink(profile?.socialMediaLinks, 'linkedin'),
      );
      _facebookController = TextEditingController(
        text: _getSocialLink(profile?.socialMediaLinks, 'facebook'),
      );
      _twitterController = TextEditingController(
        text: _getSocialLink(profile?.socialMediaLinks, 'twitter'),
      );
      _dobController = TextEditingController(text: profile?.dob ?? '');
      _chapterController = TextEditingController(text: profile?.chapter ?? '');

      selectedIndustries = [];
      if (profile?.industries != null) {
        if (profile!.industries is List) {
          // Handle both List<String> and List<dynamic>
          // First, convert all items to strings and join them
          final industriesList = (profile.industries as List)
              .map((item) => item.toString())
              .toList();

          // Join them and then split by comma to handle cases where items contain commas
          final joinedIndustries = industriesList.join(',');
          selectedIndustries = joinedIndustries
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (profile.industries is String) {
          final industriesString = profile.industries as String;
          // Handle string that looks like a list: "[Technology,Marketing,Finance]"
          String cleanString = industriesString;
          if (cleanString.startsWith('[') && cleanString.endsWith(']')) {
            cleanString = cleanString.substring(1, cleanString.length - 1);
          }
          selectedIndustries = cleanString
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        // Remove duplicates and clean up the list
        selectedIndustries = selectedIndustries
            .map((industry) => industry.trim())
            .where((industry) => industry.isNotEmpty)
            .toSet()
            .toList();
        print('Edit Profile - Raw profile industries: ${profile.industries}');
        print(
            'Edit Profile - Raw profile industries type: ${profile.industries.runtimeType}');
        print(
            'Edit Profile - Loaded industries (cleaned): $selectedIndustries');
        print('Edit Profile - Available industries: $availableIndustries');
        print('Edit Profile - Checking selections:');
        for (String industry in availableIndustries) {
          print('  $industry: ${selectedIndustries.contains(industry)}');
        }
      }

      // Also clean up any existing duplicates in the current list
      if (selectedIndustries.isNotEmpty) {
        selectedIndustries = selectedIndustries.toSet().toList();
        print('Edit Profile - Final cleaned industries: $selectedIndustries');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Load failed';
      });
    }
  }

  String _getSocialLink(Map<String, String>? links, String platform) {
    if (links == null) return '';
    // Try both lowercase and original case
    return links[platform.toLowerCase()] ?? links[platform] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _regionController.dispose();
    _memberSinceController.dispose();
    _aboutController.dispose();
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    _websiteController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _linkedInController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _dobController.dispose();
    _chapterController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that at least one industry is selected
    if (selectedIndustries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one industry'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate at least one phone number
    final phoneNumbers = _phoneControllers
        .map((c) => c.text.trim().replaceAll(RegExp(r'[^\d]'), ''))
        .where((num) => num.isNotEmpty)
        .map((num) => int.parse(num))
        .toList();
    if (phoneNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentProfile =
          Provider.of<ProfileProvider>(context, listen: false).profile;

      // Clean and ensure industries are separate strings
      final cleanIndustries = selectedIndustries
          .map((industry) => industry.trim())
          .where((industry) => industry.isNotEmpty)
          .toList();

      print('Edit Profile - Raw selected industries: $selectedIndustries');
      print('Edit Profile - Cleaned industries for saving: $cleanIndustries');

      final updatedProfile = ProfileModel(
        id: currentProfile?.id,
        // Do NOT update imageUrl, userId, or connectionStatus here
        name: _nameController.text.trim(),
        company: _companyController.text.trim(),
        region: _regionController.text.trim(),
        memberSince: _memberSinceController.text.trim(),
        socialMediaLinks: {
          if (_linkedInController.text.isNotEmpty)
            'linkedin': _linkedInController.text.trim(),
          if (_facebookController.text.isNotEmpty)
            'facebook': _facebookController.text.trim(),
          if (_twitterController.text.isNotEmpty)
            'twitter': _twitterController.text.trim(),
        },
        about: _aboutController.text.trim(),
        dob: _dobController.text.trim(),
        chapter: _chapterController.text.trim(),
        industries: cleanIndustries,
        phonenumbers: phoneNumbers,
        email: _emailController.text.trim(),
        googleMapLocation: _locationController.text.trim(),
        website: _websiteController.text.trim(),
      );

      await Provider.of<ProfileProvider>(context, listen: false)
          .updateProfile(updatedProfile);

      if (!mounted) return;

      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Could not show success snackbar: $e');
      }

      Navigator.pop(context); // Go back to previous screen instead of replacing
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
      });
      if (mounted) {
        GlobalErrorHandler.showErrorSnackBar(context, _errorMessage!);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save, size: 30),
            )
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          // Debug: Print current state
          print(
              'Edit Profile Build - Profile industries: ${profileProvider.profile?.industries}');
          print(
              'Edit Profile Build - Selected industries: $selectedIndustries');

          // Reinitialize controllers if profile data changes and we haven't initialized yet
          if (profileProvider.profile != null &&
              (_nameController.text.isEmpty || selectedIndustries.isEmpty)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeControllers();
            });
          }

          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _initializeControllers();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileImageSection(),
                  _buildSectionHeader('Required Information'),
                  _buildTextField(
                    'Full Name*',
                    _nameController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    'Company*',
                    _companyController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Company name is required';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    'Member Since*',
                    _memberSinceController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Member since date is required';
                      }
                      return null;
                    },
                  ),
                  _buildSectionHeader('About'),
                  _buildAboutField(),
                  _buildSectionHeader('Industry*'),
                  _buildIndustryChips(),
                  if (selectedIndustries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select at least one industry',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  _buildSectionHeader('Contact Details*'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < _phoneControllers.length; i++)
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: TextFormField(
                                  controller: _phoneControllers[i],
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Phone ${i + 1}',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: buttonColor),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Phone number is required';
                                    }
                                    final digitsOnly =
                                        value.replaceAll(RegExp(r'[^\d]'), '');
                                    if (digitsOnly.length < 10) {
                                      return 'Enter a valid phone number (at least 10 digits)';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            if (_phoneControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _phoneControllers.removeAt(i);
                                  });
                                },
                              ),
                          ],
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              setState(() {
                                _phoneControllers.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add,
                                color: buttonColor, size: 20),
                            label: const Text('Add Phone Number'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Email*',
                    _emailController,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    'Website',
                    _websiteController,
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(
                                r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$')
                            .hasMatch(value)) {
                          return 'Enter a valid website URL';
                        }
                      }
                      return null;
                    },
                  ),
                  _buildTextField('Location', _locationController),
                  _buildSectionHeader('Optional Information'),
                  _buildTextField('Date of Birth', _dobController),
                  _buildSectionHeader('Social Media Links'),
                  _buildSocialMediaField('LinkedIn', _linkedInController),
                  _buildSocialMediaField('Facebook', _facebookController),
                  _buildSocialMediaField('X', _twitterController),
                  _buildSaveButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection() {
    final profile = Provider.of<ProfileProvider>(context).profile;

    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: buttonColor, width: 2),
            ),
            child: (profile?.imageUrl != null && profile!.imageUrl!.isNotEmpty)
                ? ClipOval(
                    child: Image.network(
                      profile.imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            size: 60, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Profile picture cannot be changed here.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: buttonColor,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: buttonColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator ??
            (isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                : null),
      ),
    );
  }

  Widget _buildAboutField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: _aboutController,
        maxLines: 4,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: buttonColor),
          ),
          hintText: 'Tell us about yourself...',
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildIndustryChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: availableIndustries.map((industry) {
          // Normalize both the available industry and selected industries for comparison
          final normalizedIndustry = industry.trim();
          final normalizedSelectedIndustries =
              selectedIndustries.map((e) => e.trim()).toList();

          final isSelected =
              normalizedSelectedIndustries.contains(normalizedIndustry);

          print(
              'Edit Profile - Industry chip: $normalizedIndustry, isSelected: $isSelected');

          return FilterChip(
            label: Text(industry),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  // Only add if not already in the list
                  if (!selectedIndustries.contains(industry)) {
                    selectedIndustries.add(industry);
                  }
                } else {
                  selectedIndustries.remove(industry);
                }

                print(
                    'Edit Profile - Updated selected industries: $selectedIndustries');
              });
            },
            selectedColor: buttonColor,
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            checkmarkColor: Colors.white, // <-- set tick/check color to white
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSocialMediaField(
      String platform, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: _getSocialMediaIcon(platform),
          labelText: '$platform URL',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: buttonColor),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (!Uri.tryParse(value)!.isAbsolute) {
              return 'Enter a valid URL';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 20),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
          ),
          child: const Text(
            'Save Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Icon _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return const Icon(Icons.link);
      case 'facebook':
        return const Icon(Icons.facebook);
      case 'twitter':
        return const Icon(Icons.abc);
      default:
        return const Icon(Icons.link);
    }
  }
}
