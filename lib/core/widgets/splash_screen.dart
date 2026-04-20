import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252D41),
      body: Center(
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.montserrat(
              fontSize: 42,
              fontWeight: FontWeight.w700,
            ),
            children: const [
              TextSpan(
                text: 'Reservalo',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'YA',
                style: TextStyle(color: Color(0xFF49D19E)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}