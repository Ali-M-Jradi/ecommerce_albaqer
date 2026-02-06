import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/app_theme.dart';
import 'register_screen.dart';
import 'tabs_screen.dart';

/// Login Screen - User Authentication
///
/// KEY CONCEPTS FOR PRESENTATION:
/// - Form validation (email format, password length)
/// - State management with StatefulWidget
/// - Async operations (login API call)
/// - Navigation (push/pop routes)
/// - Error handling (show errors to user)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ========================================
  // STATE VARIABLES
  // ========================================

  /// TextEditingControllers manage input field state
  /// WHY? So we can read values when user submits form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// GlobalKey for form validation
  /// WHY? Allows us to validate all fields at once
  final _formKey = GlobalKey<FormState>();

  /// AuthService instance for API calls
  /// WHY? Separation of concerns - UI separate from business logic
  final AuthService _authService = AuthService();

  /// Loading state - prevents multiple submissions
  /// WHY? User shouldn't submit form multiple times while waiting
  bool _isLoading = false;

  /// Password visibility toggle
  /// WHY? Better UX - user can verify password entry
  bool _obscurePassword = true;

  /// Error message display
  String? _errorMessage;

  // ========================================
  // LIFECYCLE METHODS
  // ========================================

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    // IMPORTANT: Always dispose controllers!
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ========================================
  // VALIDATION METHODS
  // ========================================

  /// Validate email format using regex
  /// EXPLAIN IN PRESENTATION: Why validation matters (security, UX)
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Email regex pattern
    // EXPLAIN: What is regex? Pattern matching for strings
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validate password length
  /// EXPLAIN: Why minimum length? (Security best practice)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // ========================================
  // MAIN LOGIN LOGIC
  // ========================================

  /// Handle login button press
  /// EXPLAIN IN PRESENTATION:
  /// 1. Validates form
  /// 2. Calls API
  /// 3. Handles response (success/error)
  /// 4. Navigates on success
  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    // Validate all form fields
    // EXPLAIN: Why validate? Prevent bad data from reaching server
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    // EXPLAIN: Why? Prevents multiple submissions, shows user progress
    setState(() => _isLoading = true);

    try {
      // Call auth service
      // EXPLAIN: This sends HTTP POST to backend /api/users/login
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result['success']) {
        // Login successful!
        // EXPLAIN: Navigate and remove login screen from stack
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TabsScreen()),
          );
        }
      } else {
        // Login failed - show error
        // EXPLAIN: Why setState? To trigger UI rebuild with error
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      // Network or unexpected error
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      // Always stop loading, even if error occurred
      // EXPLAIN: finally block always executes
      setState(() => _isLoading = false);
    }
  }

  // ========================================
  // UI BUILD METHOD
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with back button
      appBar: AppBar(title: const Text('Login'), centerTitle: true),

      // Body with form
      body: SafeArea(
        child: SingleChildScrollView(
          // EXPLAIN: Why SingleChildScrollView? Prevents overflow when keyboard opens
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // App Logo/Title
                Icon(Icons.diamond, size: 80, color: AppColors.secondary),
                const SizedBox(height: 16),

                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Login to your account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ========================================
                // EMAIL INPUT FIELD
                // ========================================
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // EXPLAIN: keyboardType shows email-specific keyboard
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: AppColors.secondary,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validateEmail,
                  // EXPLAIN: validator automatically called when form validates
                ),
                const SizedBox(height: 16),

                // ========================================
                // PASSWORD INPUT FIELD
                // ========================================
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  // EXPLAIN: obscureText hides password characters
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: AppColors.secondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {
                        // Toggle password visibility
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 24),

                // ========================================
                // ERROR MESSAGE DISPLAY
                // ========================================
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 24),

                // ========================================
                // LOGIN BUTTON
                // ========================================
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  // EXPLAIN: null disables button during loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        )
                      : const Text('Login', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // ========================================
                // REGISTER LINK
                // ========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to register screen
                        // EXPLAIN: Push adds screen to navigation stack
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
