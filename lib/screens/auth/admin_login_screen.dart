import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';

// ======================================================================
// BUSSYNC YELLOW / BLACK PALETTE
// ======================================================================

const Color yellow = Color(0xFFE8B949);
const Color yellowDark = Color(0xFFC99516);
const Color yellowLight = Color(0xFFFFF7DD);
const Color yellowSoft = Color(0xFFFFFCF5);

const Color black = Color(0xFF242424);
const Color textDark = Color(0xFF252525);
const Color textMuted = Color(0xFF666666);
const Color border = Color(0xFFE8E0C8);

const Color green = Color(0xFF16A34A);

// ======================================================================
// ADMIN LOGIN SCREEN
// ======================================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  // ====================================================================
  // DEMO LOGIN
  // ====================================================================

  void _fillDemoAdmin() {
    _emailController.text = 'admin@bussync.edu';
    _passwordController.text = 'admin123';

    setState(() {});
  }

  // ====================================================================
  // LOGIN
  // ====================================================================

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
    Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      if (authProvider.currentUser?.isAdmin == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This account is not registered as an Administrator.',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ====================================================================
  // BUILD
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final size = MediaQuery.of(context).size;
    final width = size.width;

    final horizontalPadding =
    (width * 0.055).clamp(18.0, 28.0);

    return Scaffold(
      backgroundColor: yellowSoft,
      body: Stack(
        children: [
          // ==============================================================
          // DECORATIVE BACKGROUND
          // ==============================================================

          Positioned(
            top: -100,
            right: -80,
            child: _GlowCircle(
              size: 240,
              color: yellow.withValues(alpha: 0.10),
            ),
          ),

          Positioned(
            bottom: -110,
            left: -100,
            child: _GlowCircle(
              size: 250,
              color: yellowDark.withValues(alpha: 0.065),
            ),
          ),

          Positioned(
            top: 320,
            right: -120,
            child: _GlowCircle(
              size: 190,
              color: yellow.withValues(alpha: 0.045),
            ),
          ),

          // ==============================================================
          // CONTENT
          // ==============================================================

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                14,
                horizontalPadding,
                28,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ====================================================
                    // TOP BAR
                    // ====================================================

                    Row(
                      children: [
                        _BackButton(
                          onTap: () => Navigator.pop(context),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                yellowLight,
                                yellowSoft,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: border,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 15,
                                color: yellowDark,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'ADMIN PORTAL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.7,
                                  color: yellowDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ====================================================
                    // GRADIENT IDENTITY
                    // ====================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        22,
                        20,
                        21,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            yellow,
                            yellowDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                            color: yellowDark.withValues(alpha: 0.18),
                            blurRadius: 25,
                            offset: const Offset(0, 11),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    yellowLight,
                                    yellowSoft,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 35,
                                color: yellowDark,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Welcome, Administrator',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Manage your college transport system',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ====================================================
                    // LOGIN CARD
                    // ====================================================

                    Container(
                      padding: EdgeInsets.all(
                        width < 360 ? 17 : 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.045),
                            blurRadius: 22,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Administrator Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Use your registered administrator account',
                            style: TextStyle(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),

                          const SizedBox(height: 19),

                          // =================================================
                          // ERROR
                          // =================================================

                          if (authProvider.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: const Color(0xFFFFCDD2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFDC2626),
                                    size: 19,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontSize: 11,
                                        height: 1.35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // =================================================
                          // EMAIL
                          // =================================================

                          _buildField(
                            controller: _emailController,
                            label: 'Admin Email',
                            hint: 'Enter your admin email',
                            icon: Icons.alternate_email_rounded,
                            keyboardType:
                            TextInputType.emailAddress,
                            textInputAction:
                            TextInputAction.next,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter admin email';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          // =================================================
                          // PASSWORD
                          // =================================================

                          _buildField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                  !_obscurePassword;
                                });
                              },
                            ),
                            onFieldSubmitted: (_) {
                              if (!authProvider.isLoading) {
                                _handleLogin();
                              }
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please enter password';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 19),

                          // =================================================
                          // LOGIN BUTTON
                          // =================================================

                          SizedBox(
                            height: 55,
                            child: Material(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: black,
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                  onTap: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  child: Center(
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                      width: 23,
                                      height: 23,
                                      child:
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                        : const Row(
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.login_rounded,
                                          size: 19,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Sign In as Admin',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ====================================================
                    // DEMO ACCOUNT
                    // ====================================================

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            yellowLight,
                            yellowSoft,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.flash_on_rounded,
                                  color: yellowDark,
                                  size: 19,
                                ),
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Demo Admin Account',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w800,
                                        color: textDark,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Quick-fill credentials for testing',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _fillDemoAdmin,
                              icon: const Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 17,
                              ),
                              label: const Text(
                                'Use Demo Admin Account',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style:
                              OutlinedButton.styleFrom(
                                foregroundColor: yellowDark,
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: border,
                                ),
                                minimumSize:
                                const Size(0, 43),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ====================================================
                    // SECURITY FOOTER
                    // ====================================================

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF8F3),
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: green,
                          ),
                        ),

                        const SizedBox(width: 7),

                        const Text(
                          'Secure administrator access',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        'BusSync • College Transport',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF999999),
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
  }

  // ====================================================================
  // TEXT FIELD
  // ====================================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(
          icon,
          color: yellowDark,
        ),

        suffixIcon: suffixIcon,

        filled: true,
        fillColor: yellowSoft,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: yellowDark,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// BACK BUTTON
// ======================================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: border,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: textDark,
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// BACKGROUND CIRCLE
// ======================================================================

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}