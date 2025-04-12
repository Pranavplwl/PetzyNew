import 'package:flutter/material.dart';
import 'package:petzy/providers/pet_provider.dart';
import 'package:petzy/widgets/pet_card.dart';
import 'package:provider/provider.dart';

class BrowsePetsTab extends StatelessWidget {
  const BrowsePetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        if (petProvider.isLoading && petProvider.pets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (petProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(petProvider.error!),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: petProvider.loadPets,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => petProvider.loadPets(),
          child: petProvider.filteredPets.isEmpty
              ? const Center(
                  child: Text(
                    'No pets found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: petProvider.filteredPets.length,
                  itemBuilder: (context, index) {
                    final pet = petProvider.filteredPets[index];
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
      },
    );
  }
}
