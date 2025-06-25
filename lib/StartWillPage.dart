import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'results_page.dart';

class StartWillPage extends StatefulWidget {
  const StartWillPage({super.key});

  @override
  State<StartWillPage> createState() => _StartWillPageState();
}

class _StartWillPageState extends State<StartWillPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  String? selectedAnswer;
  bool _isTransitioning = false;

  String? name;
  String? totalAssets;
  String? gender;
  String? country;
  String? sect;
  String? subsectSunni;
  String? subsectShia;
  String? wasMarried;
  String? totalWives;
  String? currentlyMarriedWives;
  String? divorcedWives;
  String? deceasedWives;
  String? numChildren;
  String? numAdoptedChildren;
  String? includeAdopted;
  String? adoptedDistributionMethod;
  String? numSons;
  String? numDaughters;
  String? hasParents;
  String? paternalGrandparents;
  String? maternalGrandparents;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  final Map<String, String> answers = {};

  final List<Map<String, dynamic>> questions = [
    {'key': 'name', 'question': 'What is your full name?', 'type': 'text'},
    {
      'key': 'gender',
      'question': 'What is your gender?',
      'options': ['Male', 'Female'],
    },
    {
      'key': 'total_assets',
      'type': 'number',
      'question':
          'What is the total approximate value of your assets (in your local currency)?',
    },
    {
      'key': 'country',
      'question': 'Which country are you from?',
      'options': ['Pakistan', 'Saudi Arabia', 'India'],
    },
    {
      'key': 'sect',
      'question': 'What is your school of thought?',
      'options': ['Sunni', 'Shia'],
    },
    {
      'key': 'subsect_sunni',
      'condition': (Map<String, String> ans) => ans['sect'] == 'Sunni',
      'question': 'Which Sunni sub-sect do you follow?',
      'options': ['Hanafi', 'Shafi', 'Maliki', 'Hanbali'],
    },
    {
      'key': 'subsect_shia',
      'condition': (Map<String, String> ans) => ans['sect'] == 'Shia',
      'question': 'Which Shia sub-sect do you follow?',
      'options': ['Jafari (Twelver)', 'Ismaili', 'Zaidi'],
    },
    {
      'key': 'was_married',
      'question': 'Have you ever been married?',
      'options': ['Yes', 'No'],
    },
    {
      'key': 'total_wives',
      'type': 'number',
      'question': 'How many wives have you had in total?',
      'condition':
          (Map<String, String> ans) =>
              ans['gender'] == 'Male' && ans['was_married'] == 'Yes',
    },
    {
      'key': 'currently_married_wives',
      'type': 'number',
      'question': 'How many wives are currently married to you?',
      'condition':
          (Map<String, String> ans) =>
              ans['gender'] == 'Male' && ans['was_married'] == 'Yes',
    },
    {
      'key': 'divorced_wives',
      'type': 'number',
      'question': 'How many of your wives are divorced?',
      'condition': (Map<String, String> ans) {
        if (ans['gender'] == 'Male' && ans['was_married'] == 'Yes') {
          int total = int.tryParse(ans['total_wives'] ?? '0') ?? 0;
          int current =
              int.tryParse(ans['currently_married_wives'] ?? '0') ?? 0;
          return total > current;
        }
        return false;
      },
    },
    {
      'key': 'deceased_wives',
      'type': 'number',
      'question': 'How many of your wives have passed away?',
      'condition': (Map<String, String> ans) {
        if (ans['gender'] == 'Male' && ans['was_married'] == 'Yes') {
          int total = int.tryParse(ans['total_wives'] ?? '0') ?? 0;
          int current =
              int.tryParse(ans['currently_married_wives'] ?? '0') ?? 0;
          int divorced = int.tryParse(ans['divorced_wives'] ?? '0') ?? 0;
          return (total - current - divorced) > 0;
        }
        return false;
      },
    },
    {
      'key': 'num_children',
      'type': 'number',
      'question': 'How many children do you have?',
      'condition':
          (Map<String, String> ans) =>
              ans['was_married'] == 'Yes' || ans['gender'] == 'Female',
    },
    {
      'key': 'num_adopted_children',
      'type': 'number',
      'question': 'How many of your children are adopted?',
      'condition':
          (Map<String, String> ans) =>
              int.tryParse(ans['num_children'] ?? '0') != null &&
              int.parse(ans['num_children']!) > 0,
    },
    {
      'key': 'include_adopted',
      'question':
          'Do you want to include your adopted child(ren) in your will (from the 1/3 allowed portion)?',
      'options': ['Yes', 'No'],
      'condition':
          (Map<String, String> ans) =>
              int.tryParse(ans['num_adopted_children'] ?? '0') != null &&
              int.parse(ans['num_adopted_children']!) > 0,
    },
    {
      'key': 'adopted_distribution_method',
      'question':
          'How would you like to distribute the share among your adopted child(ren)?',
      'options': [
        'Equally among all adopted children',
        'Assign custom shares to each adopted child',
      ],
      'condition':
          (Map<String, String> ans) =>
              ans['include_adopted'] == 'Yes' &&
              int.tryParse(ans['num_adopted_children'] ?? '0') != null &&
              int.parse(ans['num_adopted_children']!) > 1,
    },
    {
      'key': 'num_sons',
      'type': 'number',
      'question': 'How many of them are sons?',
      'condition': (Map<String, String> ans) {
        int total = int.tryParse(ans['num_children'] ?? '0') ?? 0;
        return total > 0;
      },
      'validate': (String? value, Map<String, String> ans) {
        int? input = int.tryParse(value ?? '');
        int total = int.tryParse(ans['num_children'] ?? '0') ?? 0;

        if (input == null || input < 0) {
          return 'Please enter a valid number of sons.';
        } else if (input > total) {
          return 'Number of sons cannot be more than total children.';
        }
        return null;
      },
    },
    {
      'key': 'has_parents',
      'question': 'Are your parents alive?',
      'options': ['Both alive', 'Only father', 'Only mother', 'None'],
    },
    {
      'key': 'paternal_grandparents',
      'question': 'Are your paternal grandparents (father’s parents) alive?',
      'options': ['Both alive', 'Only grandfather', 'Only grandmother', 'None'],
      'condition': (Map<String, String> ans) {
        return ans['has_parents'] == 'Only mother' ||
            ans['has_parents'] == 'None';
      },
    },
    {
      'key': 'maternal_grandparents',
      'question': 'Are your maternal grandparents (mother’s parents) alive?',
      'options': ['Both alive', 'Only grandfather', 'Only grandmother', 'None'],
      'condition': (Map<String, String> ans) {
        return ans['has_parents'] == 'Only father' ||
            ans['has_parents'] == 'None';
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> nextQuestion() async {
    if (_isTransitioning) return;

    final currentQuestion = questions[currentIndex];
    final String key = currentQuestion['key'];

    if (selectedAnswer == null &&
        currentQuestion['type'] != 'text' &&
        currentQuestion['type'] != 'number') {
      return;
    }

    answers[key] = selectedAnswer ?? answers[key] ?? '';

    switch (key) {
      case 'name':
        name = answers[key];
        break;
      case 'total_assets':
        totalAssets = answers[key];
        break;

      case 'gender':
        gender = answers[key];
        break;
      case 'country':
        country = answers[key];
        break;
      case 'sect':
        sect = answers[key];
        break;
      case 'subsect_sunni':
        subsectSunni = answers[key];
        break;
      case 'subsect_shia':
        subsectShia = answers[key];
        break;
      case 'was_married':
        wasMarried = answers[key];
        break;
      case 'total_wives':
        totalWives = answers[key];
        break;
      case 'currently_married_wives':
        currentlyMarriedWives = answers[key];
        break;
      case 'divorced_wives':
        divorcedWives = answers[key];
        break;
      case 'deceased_wives':
        deceasedWives = answers[key];
        break;
      case 'num_children':
        numChildren = answers[key];
        break;
      case 'num_adopted_children':
        numAdoptedChildren = answers[key];
        break;
      case 'include_adopted':
        includeAdopted = answers[key];
        break;
      case 'adopted_distribution_method':
        adoptedDistributionMethod = answers[key];
        break;
      case 'num_sons':
        numSons = answers[key];

        final int total = int.tryParse(numChildren ?? '0') ?? 0;
        final int sons = int.tryParse(numSons ?? '0') ?? 0;

        if (sons <= total) {
          numDaughters = (total - sons).toString();
        } else {
          numDaughters = '0';
          numSons = total.toString();
        }
        answers['num_daughters'] = numDaughters!;
        break;
      case 'has_parents':
        hasParents = answers[key];
        break;
      case 'paternal_grandparents':
        paternalGrandparents = answers[key];
        break;
      case 'maternal_grandparents':
        maternalGrandparents = answers[key];
        break;
    }

    selectedAnswer = null;
    setState(() => _isTransitioning = true);

    await _animationController.reverse();
    _animationController.reset();

    setState(() {
      int nextIndex = currentIndex + 1;

      while (nextIndex < questions.length) {
        final nextQuestion = questions[nextIndex];

        bool shouldShow = true;
        if (nextQuestion.containsKey('condition')) {
          try {
            shouldShow = nextQuestion['condition'](answers);
          } catch (e) {
            shouldShow = false;
            debugPrint(
              'Error evaluating condition for ${nextQuestion['key']}: $e',
            );
          }
        }

        if (shouldShow) {
          currentIndex = nextIndex;
          return;
        }

        nextIndex++;
      }

      final result = calculateInheritanceShares({
        ...answers,
        'subsect':
            answers['sect'] == 'Sunni'
                ? answers['subsect_sunni']
                : answers['subsect_shia'],
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultsPage(results: result, totalAssets: totalAssets),
        ),
      );
    });

    await _animationController.forward();
    setState(() => _isTransitioning = false);
  }

  Widget _buildTextQuestion(Map<String, dynamic> q, Key key) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        key: key,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(q['question'], style: questionStyle),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => setState(() => answers[q['key']] = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your answer',
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberQuestion(Map<String, dynamic> q, Key key) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        key: key,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(q['question'], style: questionStyle),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => answers[q['key']] = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a number',
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsQuestion(Map<String, dynamic> q, Key key) {
    final options = q['options'] as List<String>;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        key: key,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(q['question'], style: questionStyle),
            const SizedBox(height: 20),
            ...options.map(
              (option) => _buildOptionItem(option, options.indexOf(option)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(String option, int index) {
    final delay = (index + 1) * 0.15;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final itemAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay.clamp(0, 0.8),
            (delay + 0.5).clamp(0, 1),
            curve: Curves.easeOutBack,
          ),
        );
        return FadeTransition(
          opacity: itemAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.5, 0),
              end: Offset.zero,
            ).animate(itemAnimation),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => selectedAnswer = option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                selectedAnswer == option
                    ? const Color(0xFF004E64)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF004E64), width: 1.5),
            boxShadow:
                selectedAnswer == option
                    ? [
                      BoxShadow(
                        color: const Color(0xFF004E64).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            option,
            style: TextStyle(
              color:
                  selectedAnswer == option
                      ? Colors.white
                      : const Color(0xFF004E64),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestion(Map<String, dynamic> q, {Key? key}) {
    if (q['type'] == 'text') {
      return _buildTextQuestion(q, key!);
    } else if (q['type'] == 'number') {
      return _buildNumberQuestion(q, key!);
    } else {
      return _buildOptionsQuestion(q, key!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentIndex];
    final isButtonEnabled =
        (selectedAnswer != null) ||
        (currentQuestion['type'] == 'text' &&
            (answers[currentQuestion['key']]?.isNotEmpty ?? false)) ||
        (currentQuestion['type'] == 'number' &&
            (answers[currentQuestion['key']]?.isNotEmpty ?? false));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Will'),
        backgroundColor: const Color(0xFF004E64),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return animation.status == AnimationStatus.reverse
                    ? FadeTransition(opacity: animation, child: child)
                    : SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: child,
                    );
              },
              child: buildQuestion(
                currentQuestion,
                key: ValueKey(currentIndex),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ElevatedButton(
              onPressed:
                  isButtonEnabled && !_isTransitioning ? nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002A38),
                disabledBackgroundColor: const Color(
                  0xFF002A38,
                ).withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF002A38).withOpacity(0.5),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get questionStyle => GoogleFonts.scheherazadeNew(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF004E64),
  );
}

Map<String, double> calculateInheritanceShares(Map<String, dynamic> data) {
  final String sect = data['sect'] ?? '';
  final String subsect =
      sect == 'Sunni' ? data['subsect_sunni'] : data['subsect_shia'];

  if (sect == 'Sunni' && subsect == 'Hanafi') {
    return _calculateHanafiShares(data);
  }

  if (sect == 'Sunni' && subsect == 'Shafi') {
    return _calculateShafiShares(data);
  }

  if (sect == 'Sunni' && subsect == 'Maliki') {
    return _calculateMalikiShares(data);
  }

  if (sect == 'Sunni' && subsect == 'Hanbali') {
    return _calculateHanbaliShares(data);
  }

  if (sect == 'Shia' && subsect == 'Jafari (Twelver)') {
    return _calculateJafariShares(data);
  }

  if (sect == 'Shia' && subsect == 'Ismaili') {
    return _calculateIsmailiShares(data);
  }

  if (sect == 'Shia' && subsect == 'Zaidi') {
    return _calculateZaidiShares(data);
  }

  // remaining sects/subsects
  return {
    'Error': 0.0,
  };
}
Map<String, double> _calculateHanafiShares(Map<String, dynamic> data) {
  double total = double.tryParse(data['total_assets'] ?? '0') ?? 0.0;

  // Core info
  int sons = int.tryParse(data['num_sons'] ?? '0') ?? 0;
  int daughters = int.tryParse(data['num_daughters'] ?? '0') ?? 0;
  String gender = data['gender'] ?? '';
  String wasMarried = data['was_married'] ?? 'No';
  String hasParents = data['has_parents'] ?? 'None';
  int numWives = int.tryParse(data['currently_married_wives'] ?? '0') ?? 0;

  // Grandparents
  String paternalGrandparents = data['paternal_grandparents'] ?? 'None';
  String maternalGrandparents = data['maternal_grandparents'] ?? 'None';

  // Adopted children (1/3 portion)
  int numAdopted = int.tryParse(data['num_adopted_children'] ?? '0') ?? 0;
  String includeAdopted = data['include_adopted'] ?? 'No';
  String adoptedDistMethod = data['adopted_distribution_method'] ?? '';
  bool wantsToIncludeAdopted = includeAdopted == 'Yes';

  Map<String, double> shares = {};
  double remaining = total;

  // Allocate 1/3 portion to adopted children if allowed
  double oneThird = total * (1 / 3);
  if (wantsToIncludeAdopted && numAdopted > 0) {
    if (adoptedDistMethod == 'Equally among all adopted children' || numAdopted == 1) {
      double share = oneThird / numAdopted;
      for (int i = 1; i <= numAdopted; i++) {
        shares['Adopted Child $i'] = share;
      }
    }
    //custom shares still to be done
    remaining -= oneThird;
  }

  // Spouse
  bool husbandAlive = gender == 'Female' && wasMarried == 'Yes';
  bool wifeAlive = gender == 'Male' && wasMarried == 'Yes' && numWives > 0;

  if (husbandAlive) {
    double husbandShare = (sons + daughters > 0) ? total * 0.25 : total * 0.5;
    shares['Husband'] = husbandShare;
    remaining -= husbandShare;
  } else if (wifeAlive) {
    double wifeShare = (sons + daughters > 0) ? total * 0.125 : total * 0.25;
    double totalWivesShare = wifeShare;
    shares['Wives (total)'] = totalWivesShare;
    remaining -= totalWivesShare;
  }

  //Parents
  if (hasParents == 'Both alive' || hasParents == 'Only mother') {
    double motherShare = total * (1 / 6);
    shares['Mother'] = motherShare;
    remaining -= motherShare;
  }

  if (hasParents == 'Both alive' || hasParents == 'Only father') {
    double fatherShare = (sons + daughters == 0)
        ? remaining
        : total * (1 / 6);
    shares['Father'] = fatherShare;
    remaining -= (sons + daughters > 0) ? fatherShare : 0;
  }

  //Children (sons get 2x daughters)
  final int parts = sons * 2 + daughters;
  if (parts > 0 && remaining > 0) {
    double perPart = remaining / parts;
    if (sons > 0) shares['Sons (total)'] = perPart * sons * 2;
    if (daughters > 0) shares['Daughters (total)'] = perPart * daughters;
    remaining = 0;
  }

  //  Paternal Grandparents (only if no parents)
  if ((hasParents == 'None' || hasParents == 'Only mother') &&
      (paternalGrandparents == 'Both alive' || paternalGrandparents == 'Only grandfather')) {
    if (remaining > 0) {
      shares['Paternal Grandfather'] = remaining;
      remaining = 0;
    }
  }

  //Maternal Grandparents (only if no parents)
  if ((hasParents == 'None' || hasParents == 'Only father') &&
      (maternalGrandparents == 'Both alive' || maternalGrandparents == 'Only grandmother')) {
    if (remaining > 0) {
      shares['Maternal Grandmother'] = remaining;
      remaining = 0;
    }
  }

  // Final fallback
  if (remaining > 0) {
    shares['Unallocated (Remaining)'] = remaining;
  }

  return shares;
}

Map<String, double> _calculateShafiShares(Map<String, dynamic> data) {
  double total = double.tryParse(data['total_assets'] ?? '0') ?? 0.0;


  int sons = int.tryParse(data['num_sons'] ?? '0') ?? 0;
  int daughters = int.tryParse(data['num_daughters'] ?? '0') ?? 0;
  String gender = data['gender'] ?? '';
  String wasMarried = data['was_married'] ?? 'No';
  String hasParents = data['has_parents'] ?? 'None';
  int numWives = int.tryParse(data['currently_married_wives'] ?? '0') ?? 0;

  // Grandparents
  String paternalGrandparents = data['paternal_grandparents'] ?? 'None';
  String maternalGrandparents = data['maternal_grandparents'] ?? 'None';

  // Adopted
  int numAdopted = int.tryParse(data['num_adopted_children'] ?? '0') ?? 0;
  String includeAdopted = data['include_adopted'] ?? 'No';
  String adoptedDistMethod = data['adopted_distribution_method'] ?? '';
  bool wantsToIncludeAdopted = includeAdopted == 'Yes';

  Map<String, double> shares = {};
  double remaining = total;

  // Allocate 1/3 portion to adopted children (will-based portion)
  double oneThird = total * (1 / 3);
  if (wantsToIncludeAdopted && numAdopted > 0) {
    if (adoptedDistMethod == 'Equally among all adopted children' || numAdopted == 1) {
      double share = oneThird / numAdopted;
      for (int i = 1; i <= numAdopted; i++) {
        shares['Adopted Child $i'] = share;
      }
    }
    remaining -= oneThird;
  }

  // Spouse Shares
  bool husbandAlive = gender == 'Female' && wasMarried == 'Yes';
  bool wifeAlive = gender == 'Male' && wasMarried == 'Yes' && numWives > 0;

  if (husbandAlive) {
    double husbandShare = (sons + daughters > 0) ? total * 0.25 : total * 0.5;
    shares['Husband'] = husbandShare;
    remaining -= husbandShare;
  } else if (wifeAlive) {
    double wifeShare = (sons + daughters > 0) ? total * 0.125 : total * 0.25;
    double totalWivesShare = wifeShare;
    shares['Wives (total)'] = totalWivesShare;
    remaining -= totalWivesShare;
  }

  // Parents
  if (hasParents == 'Both alive' || hasParents == 'Only mother') {
    double motherShare = (sons + daughters > 0) ? total * (1 / 6) : total * (1 / 3);
    shares['Mother'] = motherShare;
    remaining -= motherShare;
  }

  if (hasParents == 'Both alive' || hasParents == 'Only father') {
    double fatherShare = (sons + daughters == 0)
        ? remaining // residual
        : total * (1 / 6);
    shares['Father'] = fatherShare;
    remaining -= (sons + daughters > 0) ? fatherShare : 0;
  }

  // Children (sons get 2x daughters)
  final int parts = sons * 2 + daughters;
  if (parts > 0 && remaining > 0) {
    double perPart = remaining / parts;
    if (sons > 0) shares['Sons (total)'] = perPart * sons * 2;
    if (daughters > 0) shares['Daughters (total)'] = perPart * daughters;
    remaining = 0;
  }

  // Grandparents (only if parents not alive)
  if ((hasParents == 'None' || hasParents == 'Only mother') &&
      (paternalGrandparents == 'Both alive' || paternalGrandparents == 'Only grandfather')) {
    if (remaining > 0) {
      shares['Paternal Grandfather'] = remaining;
      remaining = 0;
    }
  }

  if ((hasParents == 'None' || hasParents == 'Only father') &&
      (maternalGrandparents == 'Both alive' || maternalGrandparents == 'Only grandmother')) {
    if (remaining > 0) {
      shares['Maternal Grandmother'] = remaining;
      remaining = 0;
    }
  }

  //Fallback
  if (remaining > 0) {
    shares['Unallocated (Remaining)'] = remaining;
  }

  return shares;
}

Map<String, double> _calculateMalikiShares(Map<String, dynamic> data) {
  double total = double.tryParse(data['total_assets'] ?? '0') ?? 0.0;

  int sons = int.tryParse(data['num_sons'] ?? '0') ?? 0;
  int daughters = int.tryParse(data['num_daughters'] ?? '0') ?? 0;
  String gender = data['gender'] ?? '';
  String wasMarried = data['was_married'] ?? 'No';
  String hasParents = data['has_parents'] ?? 'None';

  int numWives = int.tryParse(data['currently_married_wives'] ?? '0') ?? 0;
  String paternalGrandparents = data['paternal_grandparents'] ?? 'None';
  String maternalGrandparents = data['maternal_grandparents'] ?? 'None';

  int numAdopted = int.tryParse(data['num_adopted_children'] ?? '0') ?? 0;
  String includeAdopted = data['include_adopted'] ?? 'No';
  String adoptedDistMethod = data['adopted_distribution_method'] ?? '';
  bool wantsToIncludeAdopted = includeAdopted == 'Yes';

  Map<String, double> shares = {};
  double remaining = total;

  // Optional 1/3 for adopted children
  double oneThird = total / 3;
  if (wantsToIncludeAdopted && numAdopted > 0) {
    double adoptedShare = oneThird;
    if (adoptedDistMethod == 'Equally among all adopted children' || numAdopted == 1) {
      double share = adoptedShare / numAdopted;
      for (int i = 1; i <= numAdopted; i++) {
        shares['Adopted Child $i'] = share;
      }
    }
    remaining -= adoptedShare;
  }

  // Spouse shares
  bool husbandAlive = gender == 'Female' && wasMarried == 'Yes';
  bool wifeAlive = gender == 'Male' && wasMarried == 'Yes' && numWives > 0;

  if (husbandAlive) {
    double husbandShare = (sons + daughters > 0) ? total * 0.25 : total * 0.5;
    shares['Husband'] = husbandShare;
    remaining -= husbandShare;
  } else if (wifeAlive) {
    double wifeShare = (sons + daughters > 0) ? total * 0.125 : total * 0.25;
    double totalWivesShare = wifeShare;
    shares['Wives (total)'] = totalWivesShare;
    remaining -= totalWivesShare;
  }

  // Parents
  if (hasParents == 'Both alive' || hasParents == 'Only mother') {
    double motherShare = (sons + daughters > 0) ? total * 1 / 6 : total * 1 / 3;
    shares['Mother'] = motherShare;
    remaining -= motherShare;
  }

  if (hasParents == 'Both alive' || hasParents == 'Only father') {
    double fatherShare = (sons + daughters > 0) ? total * 1 / 6 : remaining;
    shares['Father'] = fatherShare;
    if (sons + daughters > 0) remaining -= fatherShare;
    else remaining = 0;
  }

  // Children
  int parts = sons * 2 + daughters;
  if (parts > 0 && remaining > 0) {
    double perPart = remaining / parts;
    if (sons > 0) shares['Sons (total)'] = perPart * sons * 2;
    if (daughters > 0) shares['Daughters (total)'] = perPart * daughters;
    remaining = 0;
  }

  //  Grandparents (if parents missing)
  if (hasParents == 'None') {
    if (paternalGrandparents == 'Only grandfather' || paternalGrandparents == 'Both alive') {
      shares['Paternal Grandfather'] = remaining;
      remaining = 0;
    } else if (maternalGrandparents == 'Only grandmother' || maternalGrandparents == 'Both alive') {
      shares['Maternal Grandmother'] = remaining;
      remaining = 0;
    }
  }

  // Fallback
  if (remaining > 0) {
    shares['Unallocated (Remaining)'] = remaining;
  }

  return shares;
}

Map<String, double> _calculateHanbaliShares(Map<String, dynamic> data) {
  double total = double.tryParse(data['total_assets'] ?? '0') ?? 0.0;

  int sons = int.tryParse(data['num_sons'] ?? '0') ?? 0;
  int daughters = int.tryParse(data['num_daughters'] ?? '0') ?? 0;
  String gender = data['gender'] ?? '';
  String wasMarried = data['was_married'] ?? 'No';
  String hasParents = data['has_parents'] ?? 'None';

  int numWives = int.tryParse(data['currently_married_wives'] ?? '0') ?? 0;
  String paternalGrandparents = data['paternal_grandparents'] ?? 'None';
  String maternalGrandparents = data['maternal_grandparents'] ?? 'None';

  int numAdopted = int.tryParse(data['num_adopted_children'] ?? '0') ?? 0;
  String includeAdopted = data['include_adopted'] ?? 'No';
  String adoptedDistMethod = data['adopted_distribution_method'] ?? '';
  bool wantsToIncludeAdopted = includeAdopted == 'Yes';

  Map<String, double> shares = {};
  double remaining = total;

  // Optional 1/3 for adopted children
  double oneThird = total / 3;
  if (wantsToIncludeAdopted && numAdopted > 0) {
    double adoptedShare = oneThird;
    if (adoptedDistMethod == 'Equally among all adopted children' || numAdopted == 1) {
      double share = adoptedShare / numAdopted;
      for (int i = 1; i <= numAdopted; i++) {
        shares['Adopted Child $i'] = share;
      }
    }
    remaining -= adoptedShare;
  }

  // Spouse shares
  bool husbandAlive = gender == 'Female' && wasMarried == 'Yes';
  bool wifeAlive = gender == 'Male' && wasMarried == 'Yes' && numWives > 0;

  if (husbandAlive) {
    double husbandShare = (sons + daughters > 0) ? total * 0.25 : total * 0.5;
    shares['Husband'] = husbandShare;
    remaining -= husbandShare;
  } else if (wifeAlive) {
    double wifeShare = (sons + daughters > 0) ? total * 0.125 : total * 0.25;
    shares['Wives (total)'] = wifeShare;
    remaining -= wifeShare;
  }

  // Parents
  if (hasParents == 'Both alive' || hasParents == 'Only mother') {
    double motherShare = (sons + daughters > 0) ? total * 1 / 6 : total * 1 / 3;
    shares['Mother'] = motherShare;
    remaining -= motherShare;
  }

  if (hasParents == 'Both alive' || hasParents == 'Only father') {
    double fatherShare = (sons + daughters > 0) ? total * 1 / 6 : remaining;
    shares['Father'] = fatherShare;
    if (sons + daughters > 0) remaining -= fatherShare;
    else remaining = 0;
  }

  //Children (sons : daughters = 2 : 1)
  int parts = sons * 2 + daughters;
  if (parts > 0 && remaining > 0) {
    double perPart = remaining / parts;
    if (sons > 0) shares['Sons (total)'] = perPart * sons * 2;
    if (daughters > 0) shares['Daughters (total)'] = perPart * daughters;
    remaining = 0;
  }

  // Grandparents (used if parents are not alive)
  if (hasParents == 'None') {
    if (paternalGrandparents == 'Only grandfather' || paternalGrandparents == 'Both alive') {
      shares['Paternal Grandfather'] = remaining;
      remaining = 0;
    } else if (maternalGrandparents == 'Only grandmother' || maternalGrandparents == 'Both alive') {
      shares['Maternal Grandmother'] = remaining;
      remaining = 0;
    }
  }

  // Fallback
  if (remaining > 0) {
    shares['Unallocated (Remaining)'] = remaining;
  }

  return shares;
}

Map<String, double> _calculateJafariShares(Map<String, dynamic> data) {
  double total = double.tryParse(data['total_assets'] ?? '0') ?? 0.0;

  int sons = int.tryParse(data['num_sons'] ?? '0') ?? 0;
  int daughters = int.tryParse(data['num_daughters'] ?? '0') ?? 0;
  String gender = data['gender'] ?? '';
  String wasMarried = data['was_married'] ?? 'No';
  String hasParents = data['has_parents'] ?? 'None';

  int numWives = int.tryParse(data['currently_married_wives'] ?? '0') ?? 0;
  bool husbandAlive = gender == 'Female' && wasMarried == 'Yes';
  bool wifeAlive = gender == 'Male' && wasMarried == 'Yes' && numWives > 0;

  Map<String, double> shares = {};
  double remaining = total;

  // Spouse
  if (husbandAlive) {
    double husbandShare = (sons + daughters > 0) ? total * 0.25 : total * 0.5;
    shares['Husband'] = husbandShare;
    remaining -= husbandShare;
  } else if (wifeAlive) {
    double wifeShare = (sons + daughters > 0) ? total * 0.125 : total * 0.25;
    double totalWivesShare = wifeShare; // divided equally if multiple wives
    shares['Wives (total)'] = totalWivesShare;
    remaining -= totalWivesShare;
  }

  // Parents
  if (hasParents == 'Both alive' || hasParents == 'Only mother') {
    double motherShare = (sons + daughters > 0) ? total * 0.1667 : total * 0.3333;
    shares['Mother'] = motherShare;
    remaining -= motherShare;
  }

  if (hasParents == 'Both alive' || hasParents == 'Only father') {
    double fatherShare = total * 0.1667;
    shares['Father'] = fatherShare;
    remaining -= fatherShare;
  }

  // Children
  final int parts = sons * 2 + daughters;
  if (parts > 0 && remaining > 0) {
    double perPart = remaining / parts;
    if (sons > 0) shares['Sons (total)'] = perPart * sons * 2;
    if (daughters > 0) shares['Daughters (total)'] = perPart * daughters;
  }

  return shares;
}

Map<String, double> _calculateIsmailiShares(Map<String, dynamic> data) {
  double total = double.tryParse(data['total_assets'] ?? '0') ?? 0.0;

  int sons = int.tryParse(data['num_sons'] ?? '0') ?? 0;
  int daughters = int.tryParse(data['num_daughters'] ?? '0') ?? 0;
  String gender = data['gender'] ?? '';
  String wasMarried = data['was_married'] ?? 'No';
  String hasParents = data['has_parents'] ?? 'None';

  int numWives = int.tryParse(data['currently_married_wives'] ?? '0') ?? 0;
  bool husbandAlive = gender == 'Female' && wasMarried == 'Yes';
  bool wifeAlive = gender == 'Male' && wasMarried == 'Yes' && numWives > 0;

  Map<String, double> shares = {};
  double remaining = total;

  // Spouse
  if (husbandAlive) {
    double husbandShare = (sons + daughters > 0) ? total * 0.25 : total * 0.5;
    shares['Husband'] = husbandShare;
    remaining -= husbandShare;
  } else if (wifeAlive) {
    double wifeShare = (sons + daughters > 0) ? total * 0.125 : total * 0.25;
    double totalWivesShare = wifeShare;
    shares['Wives (total)'] = totalWivesShare;
    remaining -= totalWivesShare;
  }

  //  Parents
  if (hasParents == 'Both alive' || hasParents == 'Only mother') {
    double motherShare = (sons + daughters > 0) ? total * 0.1667 : total * 0.3333;
    shares['Mother'] = motherShare;
    remaining -= motherShare;
  }

  if (hasParents == 'Both alive' || hasParents == 'Only father') {
    double fatherShare = total * 0.1667;
    shares['Father'] = fatherShare;
    remaining -= fatherShare;
  }

  // Children
  final int parts = sons * 2 + daughters;
  if (parts > 0 && remaining > 0) {
    double perPart = remaining / parts;
    if (sons > 0) shares['Sons (total)'] = perPart * sons * 2;
    if (daughters > 0) shares['Daughters (total)'] = perPart * daughters;
  }

  return shares;
}

Map<String, double> _calculateZaidiShares(Map<String, dynamic> data) {
  double total = double.tryParse(data['total_assets'] ?? '0') ?? 0.0;

  int sons = int.tryParse(data['num_sons'] ?? '0') ?? 0;
  int daughters = int.tryParse(data['num_daughters'] ?? '0') ?? 0;
  String gender = data['gender'] ?? '';
  String wasMarried = data['was_married'] ?? 'No';
  String hasParents = data['has_parents'] ?? 'None';

  int numWives = int.tryParse(data['currently_married_wives'] ?? '0') ?? 0;
  bool husbandAlive = gender == 'Female' && wasMarried == 'Yes';
  bool wifeAlive = gender == 'Male' && wasMarried == 'Yes' && numWives > 0;

  Map<String, double> shares = {};
  double remaining = total;

  // Spouse
  if (husbandAlive) {
    double husbandShare = (sons + daughters > 0) ? total * 0.25 : total * 0.5;
    shares['Husband'] = husbandShare;
    remaining -= husbandShare;
  } else if (wifeAlive) {
    double wifeShare = (sons + daughters > 0) ? total * 0.125 : total * 0.25;
    double totalWivesShare = wifeShare;
    shares['Wives (total)'] = totalWivesShare;
    remaining -= totalWivesShare;
  }

  // Parents
  if (hasParents == 'Both alive' || hasParents == 'Only mother') {
    double motherShare = total * 0.1667;
    shares['Mother'] = motherShare;
    remaining -= motherShare;
  }

  if (hasParents == 'Both alive' || hasParents == 'Only father') {
    double fatherShare = (sons + daughters == 0)
        ? remaining // All remaining if no children
        : total * 0.1667;
    shares['Father'] = fatherShare;
    remaining -= (sons + daughters > 0) ? fatherShare : 0;
  }

  // Children
  final int parts = sons * 2 + daughters;
  if (parts > 0 && remaining > 0) {
    double perPart = remaining / parts;
    if (sons > 0) shares['Sons (total)'] = perPart * sons * 2;
    if (daughters > 0) shares['Daughters (total)'] = perPart * daughters;
  }

  return shares;
}
