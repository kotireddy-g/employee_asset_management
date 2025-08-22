import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _particleController;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _animationController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authNotifier = ref.read(authProvider.notifier);

      await authNotifier.login(
        _usernameController.text,
        _passwordController.text,
      );

      final authState = ref.read(authProvider);

      setState(() {
        _isLoading = false;
      });

      if (authState.isAuthenticated) {
        if (mounted) {
          context.go('/dashboard');
        }
      } else if (authState.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error!)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFEC4899),
                ],
              ),
            ),
            child: Stack(
              children: [
                _buildAnimatedBackground(),
                _buildLoginForm(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlesPainter(_particleController.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildWelcomeText(),
                const SizedBox(height: 40),
                _buildLoginCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Iconsax.building,
        size: 60,
        color: Colors.white,
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 600.ms)
        .scale(
      begin: const Offset(0.5, 0.5),
      end: const Offset(1.0, 1.0),
      duration: 800.ms,
      curve: Curves.elasticOut,
    )
        .rotate(begin: 0.1, end: 0, duration: 800.ms);
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
            .animate(controller: _animationController)
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          'Sign in to access your admin panel',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        )
            .animate(controller: _animationController)
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildUsernameField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberMeRow(),
          const SizedBox(height: 32),
          _buildLoginButton(),
          const SizedBox(height: 20),
          _buildForgotPasswordLink(),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.5, end: 0)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Enter your username',
        prefixIcon: const Icon(Iconsax.user),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 400.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Iconsax.lock),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Text(
          'Remember me',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // Handle forgot password
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildLoginButton() {
    final authState = ref.watch(authProvider); // If using Riverpod

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _handleLogin,
        // ... rest of button code
        child: authState.isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Signing in...'),
          ],
        )
            : const Text('Sign In'),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            // Handle sign up
          },
          child: const Text(
            'Contact Admin',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1200.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (size.width * 0.1 + (i * 37) % size.width.toInt()) +
          (animationValue * 50) % size.width;
      final y = (size.height * 0.1 + (i * 91) % size.height.toInt()) +
          (animationValue * 30) % size.height;
      final radius = 2 + (i % 3);

      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        radius.toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}