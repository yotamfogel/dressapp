import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/inspiration_screen.dart';
import '../widgets/saved_fits_screen.dart';
import '../widgets/generate_fit_screen.dart';
import '../widgets/closet_screen.dart';
import '../widgets/ai_test_widget.dart';
import '../../../shared/presentation/widgets/version_banner.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DressApp'),
        backgroundColor: const Color(0xFF461700),
        foregroundColor: const Color(0xFFFEFAD4),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AITestWidget(),
                ),
              );
            },
            tooltip: 'Test AI Backend',
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: homeState.currentIndex,
            children: const [
              SavedFitsScreen(),
              InspirationScreen(),
              GenerateFitScreen(),
              MyClosetScreen(),
            ],
          ),
          const VersionBanner(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: homeState.currentIndex,
          onTap: (index) {
            ref.read(homeProvider.notifier).setCurrentIndex(index);
          },
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Saved Fits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'Inspiration',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'Generate Fit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_outlined),
              activeIcon: Icon(Icons.checkroom),
              label: 'My Closet',
            ),

          ],
        ),
      ),
    );
  }
} 