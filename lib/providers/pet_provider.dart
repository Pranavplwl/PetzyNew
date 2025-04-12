import 'package:flutter/material.dart';
import 'package:petzy/models/pet_model.dart';
import 'package:petzy/services/pet_service.dart';

class PetProvider with ChangeNotifier {
  final PetService _petService = PetService();
  List<Pet> _pets = [];
  List<Pet> _filteredPets = [];
  String _filterType = 'all'; // 'all', 'adoption', 'foster'
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => _pets;
  List<Pet> get filteredPets => _filteredPets;
  String get filterType => _filterType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all pets
  Future<void> loadPets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _petService.getPetsStream().listen((pets) {
        _pets = pets;
        _applyFilter();
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filter
  void setFilterType(String type) {
    _filterType = type;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterType == 'all') {
      _filteredPets = List.from(_pets);
    } else {
      _filteredPets = _pets.where((pet) => pet.type == _filterType).toList();
    }
  }

  // Get pet by id
  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new pet
  Future<void> addPet(Pet pet) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _petService.addPet(pet);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
