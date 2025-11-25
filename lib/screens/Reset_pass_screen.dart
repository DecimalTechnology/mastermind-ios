import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isOTPSent = false;
  bool _isOTPVerified = false;
  String? _generatedOTP;
  DateTime? _otpGeneratedTime;

  Future<void> _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      _generatedOTP = _generateOTP();
      _otpGeneratedTime = DateTime.now();
      print('Generated OTP: $_generatedOTP');

      try {
        final response = await http.post(
          Uri.parse('$baseurl/v1/auth/password/forget'),
          body: json
              .encode({'email': _emailController.text, "otp": _generatedOTP}),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          await storage.write(key: 'resetPasswordOTP', value: _generatedOTP);
          await storage.write(
              key: 'otpGeneratedTime',
              value: _otpGeneratedTime!.toIso8601String());

          setState(() => _isOTPSent = true);
          _showSnackBar('OTP Sent Successfully');
          _showOTPDialog();
        } else {
          throw Exception('Failed to send OTP: ${response.body}');
        }
      } catch (e) {
        _showSnackBar(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOTP() async {
    final storedOTP = await storage.read(key: 'resetPasswordOTP');
    final storedTimeString = await storage.read(key: 'otpGeneratedTime');
    final storedTime = DateTime.parse(storedTimeString!);

    if (DateTime.now().isAfter(storedTime.add(const Duration(minutes: 5)))) {
      _showSnackBar('OTP has expired. Please request a new one.');
      return;
    }

    if (_otpController.text == storedOTP) {
      setState(() => _isOTPVerified = true);
      Navigator.pop(context);
      _showSnackBar('OTP verified successfully!');
    } else {
      _showSnackBar('Invalid OTP. Please try again.');
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the API to reset the password
      final response = await http.put(
        Uri.parse('$baseurl/v1/auth/password/forget'),
        body: json.encode({
          'email': _emailController.text,
          'password': _newPasswordController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _showSnackBar('Password reset successfully!');
        Navigator.pop(context); // Go back to the previous screen
      } else {
        print(response.body);
        throw Exception('Failed to reset password: ${response.body}');
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOTPDialog() {
    PlatformWidget.showPlatformDialog(
      context: context,
      title: 'Enter OTP',
      content: '',
      actions: PlatformUtils.isIOS
          ? [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: _verifyOTP,
                child: const Text('Verify OTP'),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _verifyOTP,
                child: const Text('Verify OTP'),
              ),
            ],
    );
    // Show custom dialog with text field
    if (PlatformUtils.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                placeholder: 'Enter the OTP sent to your email',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 10),
              const Text(
                'OTP is valid for 5 minutes',
                style:
                    TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: _verifyOTP,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter the OTP sent to your email',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'OTP is valid for 5 minutes',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      );
    }
  }

  String _generateOTP() {
    return (100000 + DateTime.now().millisecond % 900000).toString();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Center(child: Image.asset('assets/loginScreen/logo.png')),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('Reset Password',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    if (!_isOTPVerified)
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your email'
                            : null,
                      ),
                    if (_isOTPVerified) ...[
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a new password'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please confirm your password'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: PlatformButton(
                        onPressed: _isLoading
                            ? null
                            : _isOTPVerified
                                ? _resetPassword
                                : _sendOTP,
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        isLoading: _isLoading,
                        child: Text(
                            _isOTPVerified ? 'Reset Password' : 'Send OTP'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
