import 'package:flutter/material.dart';
import 'package:petzy/models/activity_model.dart';
import 'package:petzy/providers/activities_provider.dart';
import 'package:provider/provider.dart';

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitiesProvider>(
      builder: (context, activitiesProvider, child) {
        if (activitiesProvider.isLoading &&
            activitiesProvider.activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (activitiesProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(activitiesProvider.error!),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => activitiesProvider.loadActivities(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => activitiesProvider.loadActivities(),
          child: Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: activitiesProvider.activities.length,
              itemBuilder: (context, index) {
                final activity = activitiesProvider.activities[index];
                return ActivityCard(
                  activity: activity,
                  onEdit: () => Navigator.pushNamed(
                    context,
                    '/edit_activity',
                    arguments: activity.id,
                  ),
                  onDelete: () => _confirmDeleteActivity(
                      context, activitiesProvider, activity.id),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteActivity(
    BuildContext context,
    ActivitiesProvider provider,
    String activityId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteActivity(activityId);
    }
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              activity.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.description,
                  style: const TextStyle(fontSize: 16),
                ),
                // Removed admin-only buttons (edit/delete)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
