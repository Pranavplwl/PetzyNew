class Pet {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String gender;
  final String description;
  final List<String> imageUrls;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final String type;
  final DateTime? createdAt; // Changed from postedDate to createdAt
  final String location;
  final bool isVaccinated;
  final bool isNeutered;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.description,
    required this.imageUrls,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.type,
    this.createdAt, // Now nullable
    required this.location,
    required this.isVaccinated,
    required this.isNeutered,
  });

  factory Pet.fromMap(Map<String, dynamic> data, String id) {
    return Pet(
      id: id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? '',
      gender: data['gender'] ?? 'Male',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhone: data['ownerPhone'] ?? '',
      type: data['type'] ?? 'adoption',
      createdAt: data['createdAt']?.toDate(), // Handle Firestore timestamp
      location: data['location'] ?? '',
      isVaccinated: data['isVaccinated'] ?? false,
      isNeutered: data['isNeutered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'age': age,
      'gender': gender,
      'description': description,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'type': type,
      'createdAt': createdAt, // Will be replaced with server timestamp
      'location': location,
      'isVaccinated': isVaccinated,
      'isNeutered': isNeutered,
    };
  }
}
