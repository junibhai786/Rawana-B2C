import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/screens/auth/login_secuirty_screen.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  // Data for the three screens
  final List<OnboardingContent> _contents = [
    OnboardingContent(
      image: 'assets/images/explore.png',
      title: 'Explore the World',
      description:
      'Discover amazing destinations and create unforgettable memories with our curated travel experiences',
    ),
    OnboardingContent(
      image: 'assets/images/hotel.png',
      title: 'Book Best Hotels',
      description:
      'Find and book luxurious hotels, cozy apartments, and unique stays at the best prices worldwide',
    ),
    OnboardingContent(
      image: 'assets/images/flight.png',
      title: 'Easy Flight Booking',
      description:
      'Search, compare and book flights to any destination with just a few taps. Your journey starts here',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the custom Teal color from the design
    const Color primaryColor = Color(0xFF05A8C7);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // The subtle gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE0F7FA), // Very light teal/cyan
            ],
            stops: [0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- TOP BAR (SKIP BUTTON) ---
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: GoogleFonts.spaceGrotesk(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,

                      ),
                    ),
                  ),
                ),
              ),

              // --- PAGE VIEW (IMAGES & TEXT) ---
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // IMAGE SECTION
                          Expanded(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.center,
                              child: Image.asset(
                                _contents[index].image,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // TEXT SECTION
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // Title with Space Grotesk font
                                Text(
                                  _contents[index].title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceGrotesk(

                                    fontWeight: FontWeight.w500, // Medium
                                    fontSize: 28,
                                    height: 42 / 28, // line-height: 42px
                                    letterSpacing: 0, // 0%
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Description with Space Grotesk font
                                Text(
                                  _contents[index].description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceGrotesk(

                                    fontWeight: FontWeight.w400, // Regular
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Color(0xFF607D8B), // Blue Grey
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- BOTTOM SECTION (INDICATORS & BUTTON) ---
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                child: Column(
                  children: [
                    // DOT INDICATORS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _contents.length,
                            (index) => buildDot(index, context, primaryColor),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // NEXT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentIndex == _contents.length - 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(),
                              ),
                            );
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:  [
                            Text(
                              'Next',
                              style: GoogleFonts.spaceGrotesk(

                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the dots (Pill shape for active, circle for inactive)
  Widget buildDot(int index, BuildContext context, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentIndex == index ? 25 : 8, // Expand width if active
      decoration: BoxDecoration(
        color: _currentIndex == index ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// Model Class
class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}