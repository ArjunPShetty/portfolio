import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final int delay;
  const FadeInWidget({super.key, required this.child, this.delay = 0});

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  const ScaleOnTap({super.key, required this.child});

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}


void main() => runApp(const Portfolio());

class Portfolio extends StatelessWidget {
  const Portfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arjun P Shetty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          ),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();
  double _scrollProgress = 0.0;
  bool _showBackToTop = false;

  final List<String> _sectionTitles = [
    'Home',
    'About',
    'Education',
    'Skills',
    'Certifications',
    'Contact',
  ];

  @override
  void initState() {
    super.initState();
    _positionsListener.itemPositions.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final firstPosition = positions.first;
      setState(() {
        _scrollProgress = firstPosition.itemLeadingEdge;
        _showBackToTop = firstPosition.index > 0;
      });
    }
  }

  void _scrollToSection(int index) {
    _scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildBackground(),
          ScrollablePositionedList.builder(
            itemCount: _sectionTitles.length + 1, // Add 1 for the footer
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            itemBuilder: (context, index) {
              if (index < _sectionTitles.length) {
                switch (index) {
                  case 0: return _buildHeroSection();
                  case 1: return _buildAboutSection();
                  case 2: return _buildEducationSection();
                  case 3: return _buildSkillsSection();
                  case 4: return _buildCertificationsSection();
                  case 5: return _buildContactSection();
                  default: return Container();
                }
              } else {
                // Footer as the last scrollable item
                return _buildFooter();
              }
            },
          ),
          _buildScrollProgress(),
          _buildBackToTop(),
        ],
      ),
      // Footer is now scrollable, not fixed
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 10,
      title: const Text('ARJUN.', style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w800,
        fontSize: 24,
      )),
      centerTitle: false,
      actions: [
        ..._sectionTitles.map((title) => TextButton(
          onPressed: () => _scrollToSection(_sectionTitles.indexOf(title)),
          child: Text(title, style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          )),
        )).toList(),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('ARJUN.', style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: Colors.black,
            )),
          ),
          ..._sectionTitles.map((title) => ListTile(
            title: Text(title, style: const TextStyle(
              color: Colors.black,
            )),
            onTap: () => _scrollToSection(_sectionTitles.indexOf(title)),
          )).toList(),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(FontAwesomeIcons.linkedinIn, 'https://www.linkedin.com/in/arjun-p-shetty-8759142a1/'),
              const SizedBox(width: 15),
              _socialIcon(FontAwesomeIcons.github, 'https://github.com/ArjunPShetty'),
              const SizedBox(width: 15),
              _socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com/arjun_p_shetty'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFF6C63FF)),
      ),
    );
  }

  Widget _buildBackground() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.2, 0.3),
            radius: 0.5,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollProgress() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: LinearProgressIndicator(
        value: _scrollProgress,
        minHeight: 4,
        backgroundColor: Colors.transparent,
        color: const Color(0xFF6C63FF),
      ),
    );
  }

  Widget _buildBackToTop() {
    return AnimatedOpacity(
      opacity: _showBackToTop ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: FloatingActionButton(
            onPressed: () => _scrollToSection(0),
            backgroundColor: const Color(0xFF6C63FF),
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeInWidget(
      delay: 0,
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF).withOpacity(0.08), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6C63FF).withOpacity(0.08),
              blurRadius: 32,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInWidget(
              delay: 100,
              child: const Text('HELLO, I\'M', style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C63FF),
                letterSpacing: 2,
              )),
            ),
            const SizedBox(height: 10),
            FadeInWidget(
              delay: 300,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF2A2D3E), Color(0xFF6C63FF)],
                ).createShader(bounds),
                child: const Text('ARJUN P SHETTY', style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Montserrat',
                  letterSpacing: 2,
                )),
              ),
            ),
            const SizedBox(height: 18),
            FadeInWidget(
              delay: 500,
              child: const Text('ELECTRONICS & COMMUNICATION ENGINEER', style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A8D9B),
                letterSpacing: 1.2,
              )),
            ),
            const SizedBox(height: 24),
            FadeInWidget(
              delay: 700,
              child: const Text(
                'My name is Arjun P. Shetty, and I am an Electronics and Communication Engineer with a strong foundation in electronic circuit design communication systems, and embedded technologies. I have a passion for solving complex technical problems and applying innovative solutions to real-world challenges. My academic background and hands-on experience have equipped me with skills in hardware and software integration,programming, and system optimization. I am committed to continuous learning and staying updated with emerging technologies in the ECE domain.My goal is to contribute to cutting-edge projects that push the boundaries of technology and create meaningful impact.',
                style: TextStyle(fontSize: 20, color: Color(0xFF2A2D3E)),
              ),
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                ScaleOnTap(child: _glowButton('Contact Me', 0)),
                const SizedBox(width: 24),
                ScaleOnTap(child: _glowButton('About Me', 1, secondary: true)),
              ],
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  FadeInWidget(
                    delay: 900,
                    child: const Icon(Icons.account_box_outlined, size: 44, color: Color(0xFF6C63FF)),
                  ),
                  FadeInWidget(
                    delay: 1100,
                    child: const Icon(Icons.arrow_downward, size: 34, color: Color(0xFF6C63FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }

  Widget _glowButton(String text, int section, {bool secondary = false}) {
    return ElevatedButton(
      onPressed: () => _scrollToSection(section),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: secondary ? Colors.transparent : const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: secondary
              ? const BorderSide(color: Color(0xFF6C63FF), width: 2)
              : BorderSide.none,
        ),
        shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
        elevation: 10,
      ),
      child: Text(text, style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: secondary ? const Color(0xFF6C63FF) : Colors.white,
      )),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('About Me', style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          )),
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Get to know me better', style: TextStyle(
            fontSize: 18,
            color: Color(0xFF8A8D9B),
          )),
          const SizedBox(height: 50),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: CircleAvatar(
                    radius: 240,
                    backgroundImage: AssetImage('assets/images/arjun.jpg'),
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I\'m a Passionate Designer & Developer',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'I am an Electronics and Communication Engineer with a strong foundation in circuit design, embedded systems, and communication networks. Passionate about innovation, I aim to create efficient and reliable electronic solutions that enhance everyday life and drive technological advancement.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'My expertise spans hardware development, wireless communication, and digital systems. I enjoy tackling complex engineering challenges, learning emerging technologies, and contributing to projects that merge creativity with practical application. Dedicated and adaptable, I strive to bridge the gap between theoretical concepts and real-world implementations.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: const [
                        _InfoItem(title: 'Name:', value: 'Arjun P Shetty'),
                        _InfoItem(title: 'Email:', value: 'arjunpshetty.0@gmail.com'),
                        _InfoItem(title: 'Location:', value: 'Mangalore, India'),
                        _InfoItem(title: 'Education:', value: 'B.E. in ECE'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        _StatCard(value: '-', label: 'Years Experience'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFFF8F9FE),
      child: Column(
        children: [
          const Text('Education', style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          )),
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text('My Academic Journey', style: TextStyle(
            fontSize: 18,
            color: Color(0xFF8A8D9B),
          )),
          const SizedBox(height: 50),
          Column(
            children: const [
              _TimelineItem(
                period: '2019-2021',
                title: 'High School',
                subtitle: 'Karnataka state Board',
                description: 'Mount Carmel High School, shirthady',
                details: 'Date: 2019-2021\nbasic science, Mathematics, Social Science, English, hindi, kannada',
              ),
              _TimelineItem(
                period: '2021-2023',
                title: 'Pre-University College',
                subtitle: 'Science Stream (PCME)',
                description: 'Alva\'s Pre-University College',
                details: 'Date: 2021-2023\nPhysics, Chemistry, Mathematics, Electronics',
                rightAlign: true,
              ),
              _TimelineItem(
                period: '2023-2027',
                title: 'Bachelor of Engineering',
                subtitle: 'Electronics & Communication Engineering',
                description: 'Alva\'s Institute of Engineering and Technology',
                details: 'Date: 2023-2027\nDigital Signal Processing, Microcontrollers, VLSI Design, C++, python,Network Analysis, Communication Sysyem ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Text('My Skills', style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          )),
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Technologies I master', style: TextStyle(
            fontSize: 18,
            color: Color(0xFF8A8D9B),
          )),
          const SizedBox(height: 50),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: const [
                    _SkillBar(skill: 'Network Analysis', percentage: 95),
                    _SkillBar(skill: 'C++', percentage: 90),
                    _SkillBar(skill: 'Digital & Analog  Electronics', percentage: 85),
                    _SkillBar(skill: 'Communication System', percentage: 80),
                    _SkillBar(skill: 'Microcontroller', percentage: 75),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: const [
                    _SkillIcon(icon: FontAwesomeIcons.python, label: 'Network Analysis'),
                    _SkillIcon(icon: Icons.signal_cellular_alt, label: 'Embedded Systems'),
                    _SkillIcon(icon: Icons.code, label: 'C++'),
                    _SkillIcon(icon: Icons.bolt, label: 'Circuit Design'),
                    _SkillIcon(icon: Icons.signal_cellular_alt, label: 'Signal Processing'),
                    _SkillIcon(icon: Icons.code_off_sharp, label: 'Microcontroller'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          const Text('Certifications', style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          )),
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text('My professional qualifications', style: TextStyle(
            fontSize: 18,
            color: Color(0xFF8A8D9B),
          )),
          const SizedBox(height: 50),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4, // Show 4 certificates in a row
            childAspectRatio: 0.7,
            crossAxisSpacing: 30, // Reduced spacing for compactness
            mainAxisSpacing: 30,
            children: const [
              _CertificationCard(
                icon: FontAwesomeIcons.python,
                title: 'Python',
                issuer: 'Python Course',
                date: '14/5/2024',
                cardWidth: 120, // Decreased card size
                cardPadding: 10,
              ),
              _CertificationCard(
                icon: Icons.code_off,
                title: 'NxtWave',
                issuer: 'Build Your Own Generative AI Model',
                date: '30/11/2025',
                cardWidth: 120,
                cardPadding: 10,
              ),
              _CertificationCard(
                icon: Icons.card_membership,
                title: 'Indo-US Collaborative workshop',
                issuer: 'Challenges, Innovations and Solutions for Hazardous Materials Management',
                date: '13/2/2025',
                cardWidth: 120,
                cardPadding: 10,
              ),
              // Add a fourth certificate or leave blank for now
              _CertificationCard(
                icon: Icons.adb_rounded,
                title: 'c/c++ Basics',
                issuer: 'Alvas',
                date: '19/8/2025',
                cardWidth: 120,
                cardPadding: 10,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 700,
                      maxWidth: 900,
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Back',
                            ),
                            const SizedBox(width: 8),
                            const Text('Other Certificates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 420,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 18,
                              crossAxisSpacing: 18,
                              childAspectRatio: 0.8,
                              children: const [
                                _CertificationCard(
                                  icon: Icons.verified,
                                  title: 'Flutter Dart',
                                  issuer: 'WsCube teach',
                                  date: '10/1/2024',
                                  cardWidth: 140,
                                  cardPadding: 10,
                                ),
                                _CertificationCard(
                                  icon: Icons.verified_user,
                                  title: 'VLSI Workshop',
                                  issuer: 'AIET',
                                  date: '5/9/2024',
                                  cardWidth: 140,
                                  cardPadding: 10,
                                ),
                                _CertificationCard(
                                  icon: Icons.computer,
                                  title: 'IETE member',
                                  issuer: '',
                                  date: '22/1/2025',
                                  cardWidth: 140,
                                  cardPadding: 10,
                                ),
                                _CertificationCard(
                                  icon: Icons.school,
                                  title: 'DSA in C++',
                                  issuer: 'AIET',
                                  date: '18/8/2025',
                                  cardWidth: 140,
                                  cardPadding: 10,
                                ),
                                _CertificationCard(
                                  icon: Icons.security,
                                  title: 'Network Analysis',
                                  issuer: 'VTU',
                                  date: '6/3/2025',
                                  cardWidth: 140,
                                  cardPadding: 10,
                                ),
                                _CertificationCard(
                                  icon: Icons.language,
                                  title: 'Control Sysytem',
                                  issuer: 'alvas',
                                  date: '12/11/2024',
                                  cardWidth: 140,
                                  cardPadding: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Scroll for more if available...', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text('View More', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Text('Contact Me', style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          )),
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Get in touch', style: TextStyle(
            fontSize: 18,
            color: Color(0xFF8A8D9B),
          )),
          const SizedBox(height: 50),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Let\'s Talk',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Feel free to reach out for collaborations or just a friendly hello',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'arjunpshetty.0@gmail.com',
                        );
                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        }
                      },
                      child: _ContactInfo(
                        icon: Icons.email,
                        title: 'Email',
                        value: 'arjunpshetty.0@gmail.com',
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        final Uri mapUri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=Mangalore,Karnataka,India',
                        );
                        if (await canLaunchUrl(mapUri)) {
                          await launchUrl(mapUri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: _ContactInfo(
                        icon: Icons.location_on,
                        title: 'Location',
                        value: 'alvas,Mangalore, Karnataka, India',
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        _socialIcon(FontAwesomeIcons.linkedinIn, 'https://www.linkedin.com/in/arjun-p-shetty-8759142a1/'),
                        const SizedBox(width: 15),
                        _socialIcon(FontAwesomeIcons.github, 'https://github.com/ArjunPShetty'),
                        const SizedBox(width: 15),
                        _socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com/arjun_p_shetty'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _FormField(label: 'Your Name'),
                      const SizedBox(height: 20),
                      _FormField(label: 'Your Email'),
                      const SizedBox(height: 20),
                      _FormField(label: 'Your Phone (Optional)'),
                      const SizedBox(height: 20),
                      _FormField(label: 'Subject'),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 120,
                        child: TextField(
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Your Message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 220,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 7.0),
                            child: Text(
                              'Send Message',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: const Icon(Icons.mail_outline, color: Colors.white, size: 40),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Not Working',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'The send message feature is not in working condition. Please use the button below to send an email.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: 150, // Make button less wide
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.email, color: Colors.white, size: 18), // Slightly smaller icon
                                          label: const Text(
                                            'Send Email',
                                            style: TextStyle(fontSize: 14, color: Colors.white), // Smaller font
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6C63FF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Less padding
                                          ),
                                          onPressed: () async {
                                            final Uri emailLaunchUri = Uri(
                                              scheme: 'mailto',
                                              path: 'arjunpshetty.0@gmail.com',
                                            );
                                            if (await canLaunchUrl(emailLaunchUri)) {
                                              await launchUrl(emailLaunchUri);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
                            elevation: 12,
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: const Color(0xFF2A2D3E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ARJUN.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Creating digital experiences that inspire and engage.',
                    style: TextStyle(color: Color(0xFF8A8D9B)),),
                  const SizedBox(height: 20),
                  Row(
                    children: [

                      _socialIcon(FontAwesomeIcons.linkedinIn, 'https://www.linkedin.com/in/arjun-p-shetty-8759142a1/'),
                      const SizedBox(width: 15),
                      _socialIcon(FontAwesomeIcons.github, 'https://github.com/ArjunPShetty'),
                      const SizedBox(width: 15),
                      _socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com/arjun_p_shetty'),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Links',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ..._sectionTitles.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8A8D9B),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () => _scrollToSection(entry.key),
                      child: Text(entry.value),
                    ),
                  )).toList(),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'arjunpshetty.0@gmail.com',
                      );
                      if (await canLaunchUrl(emailLaunchUri)) {
                        await launchUrl(emailLaunchUri);
                      }
                    },
                    child: const Text(
                      'arjunpshetty.0@gmail.com',
                      style: TextStyle(
                        color: Color(0xFF8A8D9B),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mangalore, India',
                    style: TextStyle(color: Color(0xFF8A8D9B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(color: Color(0xFF33354A)),
          const SizedBox(height: 20),
          const Text(
            '© 2025 Arjun P Shetty. All rights reserved.',
            style: TextStyle(color: Color(0xFF8A8D9B)),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$title ', style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C63FF),
        )),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF252836)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8A8D9B),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String period;
  final String title;
  final String subtitle;
  final String description;
  final String details;
  final bool rightAlign;

  const _TimelineItem({
    required this.period,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.details,
    this.rightAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          if (!rightAlign) ...[
            Expanded(child: Container()),
            const SizedBox(width: 40),
          ],
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  period,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF252836)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  )),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )),
                  const SizedBox(height: 10),
                  Text(description, style: const TextStyle(
                    fontSize: 16,
                  )),
                  const SizedBox(height: 10),
                  Text(details, style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A8D9B),
                  )),
                ],
              ),
            ),
          ),
          if (rightAlign) ...[
            const SizedBox(width: 40),
            Expanded(child: Container()),
          ],
        ],
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String skill;
  final int percentage;

  const _SkillBar({required this.skill, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$percentage%'),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SkillIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF252836)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF6C63FF)),
          const SizedBox(height: 15),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CertificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String issuer;
  final String date;
  final double? cardWidth;
  final double? cardPadding;

  const _CertificationCard({
    required this.icon,
    required this.title,
    required this.issuer,
    required this.date,
    this.cardWidth,
    this.cardPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Map certificate titles to asset image paths
    String? imageAsset;
    if (title == 'Python') {
      imageAsset = 'assets/images/python.jpg';
    } else if (title == 'NxtWave') {
      imageAsset = 'assets/images/Al Model.jpg';
    } else if (title == 'Indo-US Collaborative workshop') {
      imageAsset = 'assets/images/Hazardous Materials Management.jpg';
    }

    return Container(
      width: cardWidth ?? 200,
      padding: EdgeInsets.all(cardPadding ?? 18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF23243A)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF).withOpacity(0.18), Color(0xFFFF6584).withOpacity(0.12)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C63FF).withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            issuer,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8A8D9B), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C63FF),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: imageAsset == null
                ? null
                : () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            imageAsset!,
                            fit: BoxFit.contain,
                            width: 370,
                            height: 260,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 8,
              shadowColor: const Color(0xFF6C63FF).withOpacity(0.18),
            ),
            child: const Text('View Certificate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactInfo({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF252836)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF252836)
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;

  const _FormField({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}