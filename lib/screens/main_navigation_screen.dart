import 'package:dealz/_base/constant.dart';
import 'package:dealz/screens/add_product_screen.dart';
import 'package:dealz/screens/favorites_screen.dart';
import 'package:dealz/screens/home_screen.dart';
import 'package:dealz/screens/message_screen.dart';
import 'package:dealz/screens/profil_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final _homeKey = GlobalKey<HomeScreenState>();
  late final List<Widget?> _pages = [HomeScreen(key: _homeKey), null, null, null, null];
  int _selectedIndex = 0;

  Widget _pageFor(int index) {
    switch (index) {
      case 0:
        return HomeScreen(key: _homeKey);
      case 1:
        return const FavoritesScreen();
      case 3:
        return const MessageScreen();
      case 4:
        return const ProfilScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _selectTab(int index) {
    if (index == 2) {
      _openAddListing();
      return;
    }

    setState(() {
      _selectedIndex = index;
      if (index == 0) _homeKey.currentState?.refreshFavorites();
      if (index == 1) {
        _pages[index] = FavoritesScreen(key: UniqueKey());
      } else {
        _pages[index] ??= _pageFor(index);
      }
    });
  }

  Future<void> _openAddListing() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (!mounted || created != true) return;

    _homeKey.currentState?.refreshAfterListingAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (final page in _pages) page ?? const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFECEEEB))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _navItem(0, 'Accueil', Icons.home_outlined, Icons.home_rounded),
                _navItem(1, 'Favoris', Icons.favorite_border, Icons.favorite),
                _addItem(),
                _navItem(3, 'Messagerie', Icons.chat_bubble_outline,
                    Icons.chat_bubble),
                _navItem(4, 'Profil', Icons.person_outline, Icons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, String label, IconData icon, IconData activeIcon) {
    final selected = _selectedIndex == index;
    final color = selected ? Constant.primaireColor : const Color(0xFF858B87);

    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index),
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                child: Icon(
                  selected ? activeIcon : icon,
                  key: ValueKey('$index-$selected'),
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9.5,
                  height: 1,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addItem() {
    return Expanded(
      child: InkWell(
        onTap: _openAddListing,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Constant.primaireColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 23, color: Colors.white),
              ),
              const SizedBox(height: 3),
              const Text(
                'Ajout',
                style: TextStyle(
                  color: Color(0xFF858B87),
                  fontSize: 9.5,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
