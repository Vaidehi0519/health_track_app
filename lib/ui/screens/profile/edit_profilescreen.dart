import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialBio,
    required this.initialGoal,
  });

  final String initialName;
  final String initialBio;
  final String initialGoal;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
    _goalController = TextEditingController(text: widget.initialGoal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      EditProfileResult(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        goal: _goalController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE2EEF3)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.badge_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _bioController,
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.notes_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a short bio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _goalController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveProfile(),
                      decoration: const InputDecoration(
                        labelText: 'Goal',
                        prefixIcon: Icon(Icons.flag_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your goal';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileResult {
  const EditProfileResult({
    required this.name,
    required this.bio,
    required this.goal,
  });

  final String name;
  final String bio;
  final String goal;
}
