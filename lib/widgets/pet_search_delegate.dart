import 'package:flutter/material.dart';
import 'package:petzy/models/pet_model.dart';
import 'package:petzy/widgets/pet_card.dart';

class PetSearchDelegate extends SearchDelegate {
  final List<Pet> pets;

  PetSearchDelegate(this.pets);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = pets.where((pet) {
      return pet.name.toLowerCase().contains(query.toLowerCase()) ||
          pet.breed.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final pet = results[index];
        return PetCard(
          pet: pet,
          onTap: () => Navigator.pushNamed(
            context,
            '/pet_detail',
            arguments: pet.id,
          ),
        );
      },
    );
  }
}
