import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_page.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, double> results;
  final String? totalAssets;
  final String country;

  const ResultsPage({
    super.key,
    required this.results,
    required this.totalAssets,
    required this.country,
  });

  String _getCurrencySymbol(String country) {
    switch (country.toLowerCase()) {
      case 'pakistan':
        return '₨';
      case 'india':
        return '₹';
      case 'saudi arabia':
        return '﷼';
      case 'uae':
        return 'د.إ';
      case 'uk':
        return '£';
      default:
        return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = double.tryParse(totalAssets ?? '0') ?? 0;
    final currencySymbol = _getCurrencySymbol(country);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inheritance Distribution ($country)'),
        backgroundColor: const Color(0xFF004E64),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainPage()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
            total == 0 || results.isEmpty
                ? const Center(
                  child: Text(
                    'No distribution calculated.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Assets: $currencySymbol ${total.toStringAsFixed(2)}',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF004E64),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final heir = results.keys.elementAt(index);
                          final shareAmount = results[heir]!;
                          final percent = (shareAmount / total) * 100;

                          return ListTile(
                            title: Text(
                              heir,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '$currencySymbol ${shareAmount.toStringAsFixed(2)} • ${percent.toStringAsFixed(1)}%',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
