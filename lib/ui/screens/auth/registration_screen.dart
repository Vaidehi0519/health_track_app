import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/app_shell.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _gender = 'Female';
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_acceptedTerms) {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the wellness agreement.'),
          ),
        );
      }
      return;
    }

    setState(() => _isCreatingAccount = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isCreatingAccount = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, ${_nameController.text.trim()}!')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7FFF9), Color(0xFFEAF7FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 18,
                right: -44,
                child: _GlowCircle(size: 150, color: Color(0xFF1397E5)),
              ),
              const Positioned(
                bottom: 72,
                left: -54,
                child: _GlowCircle(size: 170, color: Color(0xFF32C74E)),
              ),
              CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    sliver: SliverToBoxAdapter(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 550),
                              child: const _Header(),
                            ),
                            const SizedBox(height: 28),
                            FadeInUp(
                              delay: const Duration(milliseconds: 120),
                              duration: const Duration(milliseconds: 520),
                              child: _TextInput(
                                controller: _nameController,
                                label: 'Full name',
                                hint: 'Enter your name',
                                icon: Icons.person_rounded,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.length < 3) {
                                    return 'Name must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInUp(
                              delay: const Duration(milliseconds: 180),
                              duration: const Duration(milliseconds: 520),
                              child: _TextInput(
                                controller: _emailController,
                                label: 'Email address',
                                hint: 'you@example.com',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (!text.contains('@') ||
                                      !text.contains('.')) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInUp(
                              delay: const Duration(milliseconds: 240),
                              duration: const Duration(milliseconds: 520),
                              child: _TextInput(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Create a secure password',
                                icon: Icons.lock_rounded,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                  ),
                                ),
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            FadeInUp(
                              delay: const Duration(milliseconds: 300),
                              duration: const Duration(milliseconds: 520),
                              child: _GenderSelector(
                                selectedGender: _gender,
                                onChanged: (value) {
                                  setState(() => _gender = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            FadeInUp(
                              delay: const Duration(milliseconds: 360),
                              duration: const Duration(milliseconds: 520),
                              child: _WellnessAgreement(
                                value: _acceptedTerms,
                                onChanged: (value) {
                                  setState(() => _acceptedTerms = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 26),
                            FadeInUp(
                              delay: const Duration(milliseconds: 420),
                              duration: const Duration(milliseconds: 520),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 8,
                                    shadowColor: colorScheme.primary.withValues(
                                      alpha: 0.28,
                                    ),
                                  ),
                                  onPressed: _isCreatingAccount
                                      ? null
                                      : _createAccount,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    child: _isCreatingAccount
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            key: ValueKey('label'),
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Create account',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1397E5).withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 24),
        Text(
          'Create your\nhealth profile',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: const Color(0xFF061A3A),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Personalize tracking for your habits, progress, and wellness goals.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF607080),
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD9E7EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD9E7EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1397E5), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5484D)),
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.selectedGender,
    required this.onChanged,
  });

  final String selectedGender;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF061A3A),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _GenderOption(
                label: 'Female',
                icon: Icons.female_rounded,
                selected: selectedGender == 'Female',
                onTap: () => onChanged('Female'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderOption(
                label: 'Male',
                icon: Icons.male_rounded,
                selected: selectedGender == 'Male',
                onTap: () => onChanged('Male'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1397E5) : const Color(0xFF607080);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF7FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFF1397E5) : const Color(0xFFD9E7EE),
          width: selected ? 1.6 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF1397E5).withValues(alpha: 0.15),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WellnessAgreement extends StatelessWidget {
  const _WellnessAgreement({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF32C74E) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value
                    ? const Color(0xFF32C74E)
                    : const Color(0xFFD4E4EA),
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'I agree to use Health Tracker for consistent wellness insights.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF607080),
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}
