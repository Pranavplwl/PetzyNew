import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petzy/models/pet_model.dart';
import 'package:petzy/providers/pet_provider.dart';
import 'package:petzy/widgets/favorite_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PetDetailScreen extends StatelessWidget {
  static const routeName = '/pet_detail';

  const PetDetailScreen({super.key});

  Future<void> _contactOwner(String phoneNumber, BuildContext context) async {
    try {
      // Request phone permission
      final status = await Permission.phone.request();

      if (!status.isGranted) {
        if (await Permission.phone.shouldShowRequestRationale &&
            context.mounted) {
          // Show explanation if permission was denied before
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'Petzy needs phone permission to contact the pet owner.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(telUri)) {
        // Request permission only when we know we can potentially make the call
        final status = await Permission.phone.request();

        if (status.isGranted) {
          await launchUrl(telUri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Phone permission denied')),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No phone app available')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petId = ModalRoute.of(context)?.settings.arguments as String?;
    if (petId == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid pet ID')),
      );
    }

    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.getPetById(petId);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Pet not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          FavoriteButton(petId: pet.id),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: pet.imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        _showFullScreenImage(context, pet.imageUrls[index]),
                    child: Hero(
                      tag: 'image-${pet.id}-$index',
                      child: CachedNetworkImage(
                        imageUrl: pet.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPetHeader(pet),
                  const SizedBox(height: 16),
                  _buildSectionTitle('About'),
                  Text(
                    pet.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Details'),
                  _buildDetailRow(Icons.location_on, pet.location),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Posted ${_formatDate(pet.createdAt)}', // Now handles null
                  ),
                  _buildDetailRow(
                    Icons.medical_services,
                    pet.isVaccinated ? 'Vaccinated' : 'Not vaccinated',
                  ),
                  _buildDetailRow(
                    Icons.healing,
                    pet.isNeutered ? 'Neutered' : 'Not neutered',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Owner Information'),
                  _buildDetailRow(Icons.person, pet.ownerName),
                  _buildDetailRow(Icons.phone, pet.ownerPhone),
                  const SizedBox(height: 24),
                  _buildActionButton(pet, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHeader(Pet pet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pet.breed} • ${pet.age} • ${pet.gender}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: pet.type == 'adoption' ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            pet.type.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildActionButton(Pet pet, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => _contactOwner(pet.ownerPhone, context),
        child: Text(
          pet.type == 'adoption' ? 'Adopt ${pet.name}' : 'Foster ${pet.name}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date not available';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
