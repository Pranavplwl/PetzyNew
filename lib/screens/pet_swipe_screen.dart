import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:petzy/models/pet_model.dart';
import 'package:petzy/providers/favorites_provider.dart';
import 'package:petzy/providers/pet_provider.dart';
import 'package:petzy/widgets/pet_card.dart';
import 'package:provider/provider.dart';

class PetSwipeScreen extends StatefulWidget {
  const PetSwipeScreen({super.key});

  @override
  State<PetSwipeScreen> createState() => _PetSwipeScreenState();
}

class _PetSwipeScreenState extends State<PetSwipeScreen> {
  final CarouselController _carouselController = CarouselController();
  List<Pet> _pets = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentIndex = 0;
  final double _swipeThreshold = 50.0;
  Offset _dragStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final petProvider = context.read<PetProvider>();
      await petProvider.loadPets();

      if (!mounted) return;

      setState(() {
        _pets = petProvider.pets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load pets: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

// Update your _handleLike method:
  void _handleLike(Pet pet) async {
    final favoritesProvider = context.read<FavoritesProvider>();

    try {
      await favoritesProvider.toggleFavorite(pet.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favoritesProvider.isFavorite(pet.id)
              ? '❤️ Added ${pet.name} to favorites!'
              : 'Removed ${pet.name} from favorites'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 2),
        ),
      );
      return; // Don't go to next pet if there was an error
    }

    _goToNextPet();
  }

  void _handleDislike(Pet pet) {
    debugPrint('Disliked ${pet.name}');
    _goToNextPet();
  }

  void _handleSuperLike(Pet pet) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⭐ Super liked ${pet.name}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _goToNextPet();
  }

  void _goToNextPet() {
    if (_currentIndex < _pets.length - 1) {
      _carouselController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _handleStackFinished();
    }
  }

  void _handleStackFinished() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You\'ve seen all available pets!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onPanStart: (details) {
        _dragStart = details.globalPosition;
      },
      onPanUpdate: (details) {
        final dx = details.globalPosition.dx - _dragStart.dx;
        if (dx.abs() > _swipeThreshold) {
          if (dx > 0) {
            _handleLike(pet);
          } else {
            _handleDislike(pet);
          }
        }
      },
      onTap: () => _navigateToPetDetail(pet.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Hero(
          tag: 'pet-${pet.id}',
          child: PetCard(pet: pet),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'Unknown error'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadPets,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe to Adopt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetSwiping,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: _pets.length,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 0.9,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final pet = _pets[index];
                return _buildPetCard(pet);
              },
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            Icons.close,
            Colors.red,
            () => _handleDislike(_pets[_currentIndex]),
          ),
          _buildActionButton(
            Icons.star,
            Colors.blue,
            () => _handleSuperLike(_pets[_currentIndex]),
          ),
          _buildActionButton(
            Icons.favorite,
            Colors.green,
            () => _handleLike(_pets[_currentIndex]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: onPressed,
        ),
      ),
    );
  }

  void _navigateToPetDetail(String petId) {
    Navigator.pushNamed(
      context,
      '/pet_detail',
      arguments: petId,
    );
  }

  void _resetSwiping() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _loadPets();
  }
}
