import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../demo_store.dart';
import '../widgets/shared.dart';
import 'welcome_screen.dart';

class Country {
  const Country({
    required this.name,
    required this.code,
    required this.flag,
    required this.digitLength,
  });

  final String name;
  final String code;
  final String flag;
  final int digitLength;
}

const List<Country> kCountries = [
  Country(name: 'Pakistan', code: '+92', flag: '🇵🇰', digitLength: 11),
  Country(name: 'United States', code: '+1', flag: '🇺🇸', digitLength: 10),
  Country(name: 'United Kingdom', code: '+44', flag: '🇬🇧', digitLength: 10),
  Country(name: 'India', code: '+91', flag: '🇮🇳', digitLength: 10),
  Country(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪', digitLength: 9),
  Country(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦', digitLength: 9),
  Country(name: 'Canada', code: '+1', flag: '🇨🇦', digitLength: 10),
  Country(name: 'Australia', code: '+61', flag: '🇦🇺', digitLength: 9),
];

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.store});
  final DemoStore store;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  late Country _selectedCountry = kCountries.first;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpStep = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _generateOtp() {
    if (_phoneFormKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      setState(() => _otpStep = true);
    }
  }

  void _verifyAndLogin() {
    if (_otpFormKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      widget.store.login(_phoneController.text, _selectedCountry.code);
      Navigator.of(
        context,
      ).pushAndRemoveUntil(
        loopRoute(WelcomeScreen(store: widget.store)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Reveal(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: LoopMark(size: 64)),
                    const SizedBox(height: 28),
                    Center(
                      child: Text(
                        _otpStep
                            ? 'Verify phone number'
                            : 'Enter your phone number',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _otpStep
                            ? 'Enter the code sent to ${_selectedCountry.code} ${_phoneController.text}'
                            : 'Loop Chat will send a verification OTP code to confirm your number.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!_otpStep) ...[
                      Form(
                        key: _phoneFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'COUNTRY / REGION',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Country>(
                              key: const Key('country-picker'),
                              initialValue: _selectedCountry,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items:
                                  kCountries
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(
                                            '${c.flag}  ${c.name} (${c.code})',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCountry = val);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'PHONE NUMBER (${_selectedCountry.digitLength} DIGITS)',
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: const Key('phone-input'),
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 10,
                                    top: 14,
                                    bottom: 14,
                                  ),
                                  child: Text(
                                    _selectedCountry.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                hintText:
                                    'e.g. ${'0' * _selectedCountry.digitLength}',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your phone number.';
                                }
                                final clean = val.replaceAll(
                                  RegExp(r'\D'),
                                  '',
                                );
                                if (clean.length !=
                                    _selectedCountry.digitLength) {
                                  return 'Must be exactly ${_selectedCountry.digitLength} digits for ${_selectedCountry.name}.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                key: const Key('generate-otp'),
                                onPressed: _generateOtp,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Generate OTP'),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Form(
                        key: _otpFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OTP CODE',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              key: const Key('otp-input'),
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 6,
                              style: const TextStyle(
                                fontSize: 24,
                                letterSpacing: 8,
                                fontWeight: FontWeight.w700,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                hintText: '• • • • • •',
                                counterText: '',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter the OTP code.';
                                }
                                if (val.trim().length < 4) {
                                  return 'OTP code must be at least 4 digits.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                key: const Key('verify-otp'),
                                onPressed: _verifyAndLogin,
                                child: const Text('Verify & Continue'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed:
                                    () => setState(() => _otpStep = false),
                                child: const Text('Change phone number'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
