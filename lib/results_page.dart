import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, double> results;
  final String? totalAssets;

  const ResultsPage({
    super.key,
    required this.results,
    required this.totalAssets,
  });

  @override
  Widget build(BuildContext context) {
    final double total = double.tryParse(totalAssets ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inheritance Distribution'),
        backgroundColor: const Color(0xFF004E64),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: total == 0 || results.isEmpty
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
                    'Total Assets: ₹${total.toStringAsFixed(2)}',
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
                        String heir = results.keys.elementAt(index);
                        double shareAmount = results[heir]!;
                        double percent = ((shareAmount / total) * 100);

                        return ListTile(
                          title: Text(
                            heir,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '₹${shareAmount.toStringAsFixed(2)}  •  ${percent.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 15),
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
