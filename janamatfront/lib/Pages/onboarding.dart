import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:janamatfront/Pages/authScreen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isNepali = false;

  final List<String> nepaliGuidelines = [
    'सत्य र जिल्ला सम्बन्धित समस्या मात्र प्रस्तुत गर्नुहोस्।',
    'महत्त्वपूर्ण समस्याहरूमा सोच-विचार गरेर मतदान गर्नुहोस्।',
    'आपत्तिजनक वा बदनाम गर्ने सामग्री पोस्ट नगर्नुहोस्।',
    'सही जिल्ला नागरिकता प्रमाण पत्र आवश्यक छ।',
    'तपाईँको स्वीकृति बिना तेस्रो पक्षलाई डाटा प्रदान गरिँदैन।',
    'रेटिङको दुरुपयोग गर्दा कारवाही हुन सक्छ।',
    'अगाडि बढेर, तपाईंले हाम्रो नियम र नीतिहरू स्वीकार गर्नुभयो।',
  ];

  final List<String> englishGuidelines = [
    'Post only genuine and district-relevant issues.',
    'Vote thoughtfully on important issues.',
    'Avoid posting offensive or defamatory content.',
    'Valid district citizenship credentials are required.',
    'Data will not be shared with third parties without your consent.',
    'Misuse of ratings may result in penalties.',
    'By proceeding, you agree to our terms and policies.',
  ];

  final Color primaryColor = const Color(0xFF1A237E); // Deep Navy Blue
  final Color secondaryColor = const Color(0xFF3949AB); // Lighter Navy Blue
  final Color accentColor = const Color(0xFF64B5F6); // Light Blue accent

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    Widget? animation,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          if (animation != null) ...[
            SizedBox(
              height: 300,
              child: animation,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildGuidelinesPage() {
    List<String> guidelines = isNepali ? nepaliGuidelines : englishGuidelines;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Custom Language Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption('English', !isNepali),
                const SizedBox(width: 8),
                _buildLanguageOption('नेपाली', isNepali),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: guidelines.length,
              itemBuilder: (context, index) {
                return _buildGuidelineItem(guidelines[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String guideline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        guideline,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildLanguageOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isNepali = text == 'नेपाली';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    if (_currentPage == 2) {
      return Positioned(
        bottom: 40,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AuthScreen()),
            );
          }
          ,
          style: ElevatedButton.styleFrom(
            foregroundColor: primaryColor,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: Colors.black26,
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    return Positioned(
      bottom: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            height: 8,
            width: isActive ? 24.0 : 8.0,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildPage(
        title: 'Welcome!',
        subtitle: 'Discover and raise local issues in your community.',
        animation: Lottie.asset('assets/animations/community.json'),
      ),
      _buildPage(
        title: 'Start contributing!',
        subtitle: 'Verify your identity to join your district today!',
        animation: Lottie.asset('assets/animations/meetings.json'),
      ),
      _buildGuidelinesPage(),
    ];

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: pages,
          ),
          _buildNavigationControls(),
        ],
      ),
    );
  }
}
