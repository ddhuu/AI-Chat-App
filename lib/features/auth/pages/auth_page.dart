import 'package:ai_chat_assistant/features/chat/chat_page.dart';
import 'package:ai_chat_assistant/main.dart';
import 'package:ai_chat_assistant/shared/providers/auth_provider.dart';
import 'package:ai_chat_assistant/shared/widgets/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/privacy_policy_text.dart';

enum AuthState { login, register, forgotPassword }

class AuthPage extends StatefulWidget {
  final AuthState initialState;

  const AuthPage({super.key, this.initialState = AuthState.login});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late AuthState _currentState;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _switchState(AuthState newState) {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentState = newState;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }
    if (value != _passwordController.text) {
      return AppStrings.passwordNotMatch;
    }
    return null;
  }

  Future<void> _handleLogin() async {
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    if (emailError != null) {
      _showError(emailError);
      return;
    }
    if (passwordError != null) {
      _showError(passwordError);
      return;
    }

    setState(() => _isLoading = true);

    // API call
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result == "success") {
      _showSuccess(AppStrings.loginSuccess);
      // Navigate to ChatPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => AdManager(
            isProUser: MyApp.of(context).isProUser,
            child: const ChatPage(),
          ),
        ),
        (route) => false,
      );
    } else {
      _showError(result ?? "Login failed");
    }
  }

  Future<void> _handleRegister() async {
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);
    final confirmPasswordError = _validateConfirmPassword(
      _confirmPasswordController.text,
    );

    if (emailError != null) {
      _showError(emailError);
      return;
    }
    if (passwordError != null) {
      _showError(passwordError);
      return;
    }
    if (confirmPasswordError != null) {
      _showError(confirmPasswordError);
      return;
    }

    setState(() => _isLoading = true);

    // API call
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      '', // username not used by Stack Auth
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result == "success") {
      _showSuccess(AppStrings.registerSuccess);
      // Switch to login
      _switchState(AuthState.login);
    } else {
      _showError(result ?? "Registration failed");
    }
  }

  Future<void> _handleForgotPassword() async {
    final emailError = _validateEmail(_emailController.text);

    if (emailError != null) {
      _showError(emailError);
      return;
    }

    setState(() => _isLoading = true);

    // Mock API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccess(AppStrings.resetLinkSent);
      // Switch to login
      _switchState(AuthState.login);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Logo & Title
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: AuthLogo(),
              ),
              const SizedBox(height: 32),

              // Tab Bar for Login/Register
              if (_currentState != AuthState.forgotPassword)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          text: AppStrings.login,
                          isSelected: _currentState == AuthState.login,
                          onTap: () => _switchState(AuthState.login),
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          text: AppStrings.register,
                          isSelected: _currentState == AuthState.register,
                          onTap: () => _switchState(AuthState.register),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Auth Forms
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    if (_currentState == AuthState.forgotPassword)
                      _buildForgotPasswordForm()
                    else
                      _buildLoginRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        // Title
        const Text(
          AppStrings.forgotPassword,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập email để nhận link đặt lại mật khẩu',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Email Field
        AuthTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: AppStrings.email,
          hintText: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 24),

        // Reset Button
        AuthButton(
          text: AppStrings.sendResetLink,
          onPressed: _isLoading ? null : _handleForgotPassword,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),

        // Back to Login
        TextButton(
          onPressed: () => _switchState(AuthState.login),
          child: const Text(
            AppStrings.backToLogin,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRegisterForm() {
    final isLogin = _currentState == AuthState.login;

    return Column(
      children: [
        AuthTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          nextFocusNode: _passwordFocus,
          label: AppStrings.email,
          hintText: 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),

        // Password Field
        PasswordField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          nextFocusNode: isLogin ? null : _confirmPasswordFocus,
          label: AppStrings.password,
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),

        // Confirm Password (Register only)
        if (!isLogin) ...[
          PasswordField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            label: AppStrings.confirmPassword,
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 16),
        ],

        // Forgot Password (Login only)
        if (isLogin)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _switchState(AuthState.forgotPassword),
              child: const Text(
                AppStrings.forgotPassword,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Submit Button
        AuthButton(
          text: isLogin ? AppStrings.login : AppStrings.createAccount,
          onPressed: _isLoading
              ? null
              : (isLogin ? _handleLogin : _handleRegister),
          isLoading: _isLoading,
        ),

        // Privacy Policy (Register only)
        if (!isLogin) ...[
          const SizedBox(height: 16),
          const PrivacyPolicyText(),
        ],

        // Switch to Register/Login
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLogin
                  ? AppStrings.dontHaveAccount
                  : AppStrings.alreadyHaveAccount,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () =>
                  _switchState(isLogin ? AuthState.register : AuthState.login),
              child: Text(
                isLogin ? AppStrings.registerNow : AppStrings.loginNow,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
              child: Text(text, textAlign: TextAlign.center),
            ),
          ),
          // Animated underline indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 1.5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
