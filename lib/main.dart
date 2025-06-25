import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'StartWillPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic Wiz',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004E64),
          primary: const Color(0xFF004E64),
          secondary: const Color(0xFFD4AF37),
          background: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007F5F),
          brightness: Brightness.dark,
          primary: const Color(0xFF007F5F),
          secondary: const Color(0xFFD4AF37),
          background: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainPage(),
      routes: {
        '/startWill': (context) => const StartWillPage(),
        '/settings': (context) => const SettingsPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? expandedCard;

  final bluish = const Color(0xFF004E64);
  final softGreen = const Color(0xFF007F5F);

  void handleCardTap(String cardName) {
    if (expandedCard == cardName) {
      switch (cardName) {
        case 'will':
          Navigator.pushNamed(context, '/startWill');
          break;
        case 'settings':
          Navigator.pushNamed(context, '/settings');
          break;
        case 'previous':
          Navigator.pushNamed(context, '/history');
          break;
      }
    } else {
      setState(() {
        expandedCard = cardName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expandedCard = null),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: bluish,
          title: Text(
            'Islamic Wiz',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 6,
          shadowColor: Colors.black87,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  ExpandableCard(
                    icon: Icons.edit_note_rounded,
                    label: 'Start Will',
                    cardName: 'will',
                    isExpanded: expandedCard == 'will',
                    onTap: () => handleCardTap('will'),
                    gradient: [bluish, softGreen],
                    margin: const EdgeInsets.only(
                      left: 16,
                      top: 16,
                      bottom: 16,
                      right: 8,
                    ),
                  ),
                  ExpandableCard(
                    icon: Icons.settings,
                    label: 'Settings',
                    cardName: 'settings',
                    isExpanded: expandedCard == 'settings',
                    onTap: () => handleCardTap('settings'),
                    gradient: [Colors.deepPurple, Colors.indigo],
                    margin: const EdgeInsets.only(
                      left: 8,
                      top: 16,
                      bottom: 16,
                      right: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  ExpandableCard(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Previous Wills',
                    cardName: 'previous',
                    isExpanded: expandedCard == 'previous',
                    onTap: () => handleCardTap('previous'),
                    gradient: [Colors.orange.shade700, Colors.deepOrangeAccent],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String cardName;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<Color> gradient;
  final EdgeInsets margin;

  const ExpandableCard({
    super.key,
    required this.icon,
    required this.label,
    required this.cardName,
    required this.isExpanded,
    required this.onTap,
    required this.gradient,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(
            top: isExpanded ? 6 : margin.top,
            bottom: isExpanded ? 6 : margin.bottom,
            left: margin.left,
            right: margin.right,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(6, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    label,
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page Content')),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previous Wills')),
      body: const Center(child: Text('History Page Content')),
    );
  }
}
