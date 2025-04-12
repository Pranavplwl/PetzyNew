import 'package:flutter/material.dart';
import 'package:petzy/models/activity_model.dart';
import 'package:petzy/providers/activities_provider.dart';
import 'package:provider/provider.dart';

class EditActivityScreen extends StatefulWidget {
  static const String routeName = '/edit_activity';

  const EditActivityScreen({super.key});

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadActivityData();
  }

  void _loadActivityData() {
    final activityId = ModalRoute.of(context)?.settings.arguments as String?;
    if (activityId != null) {
      final activitiesProvider =
          Provider.of<ActivitiesProvider>(context, listen: false);
      final activity = activitiesProvider.activities.firstWhere(
        (a) => a.id == activityId,
        orElse: () => Activity(
          id: '',
          title: '',
          description: '',
          imageUrl: '',
          createdAt: DateTime.now(),
        ),
      );
      _titleController.text = activity.title;
      _descriptionController.text = activity.description;
      _imageUrlController.text = activity.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final activitiesProvider =
        Provider.of<ActivitiesProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final activityId = ModalRoute.of(context)?.settings.arguments as String?;

    try {
      final activity = Activity(
        id: activityId ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
        createdAt: DateTime.now(),
      );

      if (activityId == null) {
        await activitiesProvider.addActivity(activity);
      } else {
        await activitiesProvider.updateActivity(activity);
      }

      if (!mounted) return;
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error saving activity: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final activitiesProvider =
        Provider.of<ActivitiesProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final activityId = ModalRoute.of(context)?.settings.arguments as String;
      await activitiesProvider.deleteActivity(activityId);
      if (!mounted) return;
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error deleting activity: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = ModalRoute.of(context)?.settings.arguments != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Activity' : 'Add Activity'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Image URL is required' : null,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveActivity,
                        child: Text(isEditing ? 'Update' : 'Save'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
