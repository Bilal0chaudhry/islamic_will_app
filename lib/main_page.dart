import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'start_will_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? _expandedCard;
  static const _bluish = Color(0xFF004E64);
  static const _softGreen = Color(0xFF007F5F);

  void _handleCardTap(String cardName) {
    if (_expandedCard == cardName) {
      _navigateToPage(cardName);
    } else {
      setState(() => _expandedCard = cardName);
    }
  }

  void _navigateToPage(String routeName) {
    final page = _pageMap[routeName];
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  final Map<String, Widget> _pageMap = const {
    'will': StartWillPage(),
    'settings': SettingsPage(),
    'previous': HistoryPage(),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expandedCard = null),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _buildCard(
                    icon: Icons.edit_note_rounded,
                    label: 'Start Will',
                    cardName: 'will',
                    gradient: [_bluish, _softGreen],
                    margin: const EdgeInsets.only(
                      left: 16,
                      top: 16,
                      bottom: 16,
                      right: 8,
                    ),
                  ),
                  _buildCard(
                    icon: Icons.settings,
                    label: 'Settings',
                    cardName: 'settings',
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
            _buildCard(
              icon: Icons.insert_drive_file_rounded,
              label: 'Previous Wills',
              cardName: 'previous',
              gradient: const [Color(0xFFD4AF37), Color(0xFFF9D423)],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bluish, Color(0xFF006680)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'الوصية',
              style: GoogleFonts.scheherazadeNew(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required String cardName,
    required List<Color> gradient,
    required EdgeInsets margin,
  }) {
    final (begin, end, colors) = _getGradientSettings(cardName, gradient);

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleCardTap(cardName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(
            top: _expandedCard == cardName ? 6 : margin.top,
            bottom: _expandedCard == cardName ? 6 : margin.bottom,
            left: margin.left,
            right: margin.right,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: begin,
              end: end,
              stops: const [0.2, 0.8],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(8, 8),
                blurRadius: 16,
                spreadRadius: 1,
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
                  opacity: _expandedCard == cardName ? 1.0 : 0.0,
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

  (Alignment, Alignment, List<Color>) _getGradientSettings(
    String cardName,
    List<Color> defaultGradient,
  ) {
    switch (cardName) {
      case 'will':
        return (
          Alignment.topLeft,
          Alignment.bottomRight,
          [const Color(0xFF002D40), const Color(0xFF00A896)],
        );
      case 'settings':
        return (
          Alignment.topRight,
          Alignment.bottomLeft,
          [const Color(0xFF5E35B1), const Color(0xFF3949AB)],
        );
      case 'previous':
        return (Alignment.bottomCenter, Alignment.topCenter, defaultGradient);
      default:
        return (Alignment.center, Alignment.center, defaultGradient);
    }
  }
}
