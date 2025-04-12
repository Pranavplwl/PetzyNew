class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final List<String> favoritePetIds;
  final bool isAdmin; // Add this line

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.favoritePetIds,
    this.isAdmin = false, // Add with default value
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      favoritePetIds: List<String>.from(data['favoritePetIds'] ?? []),
      isAdmin: data['isAdmin'] ?? false, // Add this line
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'favoritePetIds': favoritePetIds,
      'isAdmin': isAdmin, // Add this line
    };
  }
}
