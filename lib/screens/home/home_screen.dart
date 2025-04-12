import 'package:flutter/material.dart';
import 'package:petzy/providers/activities_provider.dart';
import 'package:petzy/providers/favorites_provider.dart';
import 'package:petzy/providers/pet_provider.dart';
import 'package:petzy/screens/home/tabs/activities_tab.dart';
import 'package:petzy/screens/home/tabs/browse_pets_tab.dart';
import 'package:petzy/screens/home/tabs/favorites_tab.dart';
import 'package:petzy/screens/home/tabs/profile_tab.dart';
import 'package:petzy/widgets/pet_search_delegate.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isLoading = true;
  String? _errorMessage;

  // Control admin access with this flag
  static const bool isAdmin = true; // Set to false to disable admin features

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final petProvider = context.read<PetProvider>();
      final activitiesProvider = context.read<ActivitiesProvider>();

      await Future.wait([
        petProvider.loadPets(),
        activitiesProvider.loadActivities(),
      ]);

      // Load favorites without auth check
      if (mounted) {
        await context.read<FavoritesProvider>().loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = 'Failed to load data. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _initializeData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Adoption & Fostering'),
        actions: _buildAppBarActions(),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          BrowsePetsTab(),
          FavoritesTab(),
          ActivitiesTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (_currentIndex == 0) ...[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => showSearch(
              context: context,
              delegate: PetSearchDelegate(context.read<PetProvider>().pets)),
          tooltip: 'Search pets',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
          tooltip: 'Filter pets',
        ),
        IconButton(
          icon: const Icon(Icons.swipe),
          onPressed: () => Navigator.pushNamed(context, '/swipe'),
          tooltip: 'Swipe view',
        ),
      ],
      if (_currentIndex == 2 && isAdmin) ...[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/add_activity'),
          tooltip: 'Add activity',
        ),
      ],
    ];
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Browse',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_run),
          label: 'Activities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_pet'),
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 2 && isAdmin) {
      return FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_activity'),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<PetProvider>(
          builder: (context, petProvider, _) {
            // Convert the current filter type string to enum
            PetFilterType currentFilter;
            try {
              currentFilter = PetFilterType.values.firstWhere((e) =>
                  e.toString().split('.').last == petProvider.filterType);
            } catch (e) {
              currentFilter = PetFilterType.all;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Pets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...PetFilterType.values
                      .map((type) => RadioListTile<PetFilterType>(
                            title: Text(type.displayName),
                            value: type,
                            groupValue: currentFilter,
                            onChanged: (value) {
                              if (value != null) {
                                petProvider.setFilterType(
                                    value.toString().split('.').last);
                                Navigator.pop(context);
                              }
                            },
                          )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

enum PetFilterType {
  all('All Pets'),
  adoption('Adoption Only'),
  foster('Foster Only');

  final String displayName;
  const PetFilterType(this.displayName);
}
