import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/presentation/widgets/app_logo.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/models/auth_db_helper.dart';

class AuthOptionsWidget extends ConsumerStatefulWidget {
  const AuthOptionsWidget({super.key});

  @override
  ConsumerState<AuthOptionsWidget> createState() => _AuthOptionsWidgetState();
}

class _AuthOptionsWidgetState extends ConsumerState<AuthOptionsWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: SizedBox(
        height: size.height * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo section
            const AppLogo(
              size: 120,
              showBackground: true,
            ),
            
            // Welcome text
            Text(
              'Welcome to DressApp',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF461700),
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Sign in to continue',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF461700),
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Social login buttons
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 320),
                child: _buildSocialLoginButton(
                  context: context,
                  icon: Icons.g_mobiledata,
                  label: 'Continue with Google',
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                  onPressed: () async {
                    try {
                      // Configure Google Sign In with proper scopes and client ID
                      final GoogleSignIn googleSignIn = GoogleSignIn(
                        scopes: ['email', 'profile'],
                        // Add your OAuth 2.0 Client ID here
                        // clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
                      );
                      
                      final googleUser = await googleSignIn.signIn();
                      if (googleUser != null) {
                        // Get auth details
                        final googleAuth = await googleUser.authentication;
                        
                        final user = UserModel(
                          email: googleUser.email,
                          provider: 'google',
                          displayName: googleUser.displayName,
                          photoUrl: googleUser.photoUrl,
                        );
                        
                        // Use the auth provider to sign in
                        await ref.read(authProvider.notifier).signIn(user);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Signed in as: ${googleUser.email}')),
                          );
                          // Check if user has completed setup using SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          final hasCompletedSetup = prefs.getBool('setup_completed') ?? false;
                          if (hasCompletedSetup) {
                            context.go('/home');
                          } else {
                            context.go('/setup');
                          }
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Sign In cancelled')),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Google Sign In failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 320),
                child: _buildSocialLoginButton(
                  context: context,
                  icon: Icons.apple,
                  label: 'Continue with Apple',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () async {
                    try {
                      final credential = await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );
                      final email = credential.email ?? '';
                      final displayName = credential.givenName != null ? '${credential.givenName} ${credential.familyName ?? ''}'.trim() : null;
                      if (email.isNotEmpty) {
                        final user = UserModel(
                          email: email,
                          provider: 'apple',
                          displayName: displayName,
                          photoUrl: null,
                        );
                        
                        // Use the auth provider to sign in
                        await ref.read(authProvider.notifier).signIn(user);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Signed in as: $email')),
                          );
                          // Check if user has completed setup using SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          final hasCompletedSetup = prefs.getBool('setup_completed') ?? false;
                          if (hasCompletedSetup) {
                            context.go('/home');
                          } else {
                            context.go('/setup');
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Apple Sign In successful (no email returned)')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Apple Sign In failed: ${e.toString()}')),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Divider with "or"
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: const Color(0xFF461700).withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF461700).withValues(alpha: 0.6),
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: const Color(0xFF461700).withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 320),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleEmailSignIn(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEFAD4),
                      foregroundColor: const Color(0xFF461700),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue with Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Terms and privacy
            Text.rich(
              TextSpan(
                text: 'By continuing, you agree to our ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF461700).withValues(alpha: 0.6),
                  fontFamily: 'Segoe UI',
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: const Color(0xFF461700),
                      decoration: TextDecoration.underline,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: const Color(0xFF461700),
                      decoration: TextDecoration.underline,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Segoe UI',
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: borderColor ?? backgroundColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _handleEmailSignIn(BuildContext context, WidgetRef ref) {
    context.push('/email-signin');
  }
}
