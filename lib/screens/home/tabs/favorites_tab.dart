import 'package:flutter/material.dart';
import 'package:petzy/providers/favorites_provider.dart';
import 'package:petzy/widgets/pet_card.dart';
import 'package:provider/provider.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    if (favoritesProvider.isLoading && !favoritesProvider.hasInitialLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoritesProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(favoritesProvider.error!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: favoritesProvider.loadFavorites,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (favoritesProvider.favoritePets.isEmpty) {
      return const Center(
        child: Text('No favorites yet. Tap the heart icon to add pets!'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => favoritesProvider.loadFavorites(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: favoritesProvider.favoritePets.length,
        itemBuilder: (context, index) {
          final pet = favoritesProvider.favoritePets[index];
          return PetCard(
            pet: pet,
            onTap: () => Navigator.pushNamed(
              context,
              '/pet_detail',
              arguments: pet.id,
            ),
          );
        },
      ),
    );
  }
}
