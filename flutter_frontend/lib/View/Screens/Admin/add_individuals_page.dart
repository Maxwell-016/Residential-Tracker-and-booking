import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/admin_side_nav.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class AddIndividualsPage extends StatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const AddIndividualsPage({
    super.key,
    required this.colorSelected,
    required this.changeTheme,
    required this.changeColor,
  });

  @override
  State<AddIndividualsPage> createState() => _AddIndividualsPageState();
}

class _AddIndividualsPageState extends State<AddIndividualsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _profilePhotoController = TextEditingController();
  String _selectedRole = 'Student'; // Default role
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addIndividual() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare user data
        final userData = {
          'Name': _nameController.text.trim(),
          'Email': _emailController.text.trim(),
          'Location': _locationController.text.trim(),
          'Phone Number': _phoneController.text.trim(),
          'Profile Photo': _profilePhotoController.text.trim(),
          'isVerified': false, // Default to false for new entries
          'Created At': FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        if (_selectedRole == 'Landlord') {
          await _firestore.collection('Landlords').add(userData);
        } else {
          await _firestore.collection('Users').add(userData);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Individual added successfully!')),
        );

        // Clear the form
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _locationController.clear();
        _profilePhotoController.clear();
        setState(() {
          _selectedRole = 'Student';
        });
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add individual: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: 'Add Individuals',
        ),
      ),
      drawer: const AdminSideNav(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'Student', child: Text('Student')),
                    DropdownMenuItem(value: 'Landlord', child: Text('Landlord')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedRole == 'Landlord') ...[
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _profilePhotoController,
                    decoration: const InputDecoration(labelText: 'Profile Photo URL (Optional)'),
                  ),
                  const SizedBox(height: 16),
                ],
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _addIndividual,
                        child: const Text('Add Individual'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}