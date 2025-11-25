import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/screens/home/Landing_screen.dart';
import 'package:master_mind/screens/Reset_pass_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError(AuthProvider authProvider) {
    if (authProvider.error != null) {
      authProvider.clearError();
    }
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (authProvider.error == null) {
      if (!mounted) return;
      if (PlatformUtils.isIOS) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => BottomNavbar()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNavbar()),
          (route) => false,
        );
      }
    }
  }

  void _navigateToResetPassword() {
    if (PlatformUtils.isIOS) {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => ResetPasswordScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return PlatformWidget.scaffold(
      context: context,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 100),
              _buildLogo(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildWelcomeText(),
                    const SizedBox(height: 20),
                    if (authProvider.error != null)
                      _buildErrorMessage(authProvider),
                    _buildEmailField(authProvider),
                    const SizedBox(height: 20),
                    _buildPasswordField(authProvider),
                    const SizedBox(height: 20),
                    _buildLoginButton(authProvider),
                    _buildForgotPasswordButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(child: Image.asset('assets/loginScreen/logo.png'));
  }

  Widget _buildWelcomeText() {
    return const Text(
      'Welcome back!',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildErrorMessage(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              authProvider.error!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _clearError(authProvider),
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(AuthProvider authProvider) {
    if (PlatformUtils.isIOS) {
      return CupertinoTextFormFieldRow(
        controller: _emailController,
        placeholder: 'Email',
        keyboardType: TextInputType.emailAddress,
        prefix: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
        ),
        onChanged: (_) => _clearError(authProvider),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!value.contains('@') || !value.contains('.')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      );
    }
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (_) => _clearError(authProvider),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AuthProvider authProvider) {
    if (PlatformUtils.isIOS) {
      return FormField<String>(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 2) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        builder: (FormFieldState<String> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                  border: field.hasError
                      ? Border.all(color: CupertinoColors.destructiveRed)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        obscureText: _obscurePassword,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(CupertinoIcons.lock,
                              color: CupertinoColors.systemGrey),
                        ),
                        onChanged: (value) {
                          field.didChange(value);
                          _clearError(authProvider);
                        },
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        child: Icon(
                          _obscurePassword
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Text(
                    field.errorText!,
                    style: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
      onChanged: (_) => _clearError(authProvider),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 2) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: PlatformButton(
        onPressed:
            authProvider.isLoading ? null : () => _handleLogin(authProvider),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        isLoading: authProvider.isLoading,
        child: const Text('Login'),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return PlatformTextButton(
      onPressed: _navigateToResetPassword,
      foregroundColor: kPrimaryColor,
      child: const Text('Forgot Password?'),
    );
  }
}
