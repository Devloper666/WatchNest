import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isForgotPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isForgotPassword
                        ? 'Reset your password'
                        : _isSignUp
                            ? 'Create your account'
                            : 'Welcome back',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isForgotPassword
                        ? 'We will send a reset link to your email.'
                        : _isSignUp
                            ? 'Join WatchNest to keep your watchlist synced.'
                            : 'Sign in to continue where you left off.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (authController.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        authController.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  if (authController.hasCompletedReset)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Password reset email sent. Check your inbox.'),
                    ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (!_isForgotPassword)
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        if (!_isSignUp && value.length < 6) {
                          return 'Password is too short.';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: authController.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            final email = _emailController.text.trim();
                            final password = _passwordController.text;

                            if (_isForgotPassword) {
                              await authController.sendPasswordResetEmail(email: email);
                            } else if (_isSignUp) {
                              await authController.registerWithEmailAndPassword(email: email, password: password);
                            } else {
                              await authController.signInWithEmailAndPassword(email: email, password: password);
                            }
                          },
                    child: Text(authController.isLoading
                        ? 'Please wait...'
                        : _isForgotPassword
                            ? 'Send reset link'
                            : _isSignUp
                                ? 'Create account'
                                : 'Sign in'),
                  ),
                  const SizedBox(height: 12),
                  if (!_isForgotPassword)
                    OutlinedButton.icon(
                      onPressed: authController.isLoading ? null : () => authController.signInWithGoogle(),
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Continue with Google'),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isForgotPassword = false;
                        _isSignUp = !_isSignUp;
                      });
                    },
                    child: Text(_isSignUp ? 'Already have an account? Sign in' : 'Need an account? Sign up'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isForgotPassword = !_isForgotPassword;
                        _isSignUp = false;
                      });
                    },
                    child: Text(_isForgotPassword ? 'Back to sign in' : 'Forgot password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
