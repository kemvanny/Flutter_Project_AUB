import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/ModernWowButton.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  File? _image;
  bool _loading = false;
  final picker = ImagePicker();

  String? _gender; // New: gender variable ("male" or "female")

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
      _showError("Failed to pick image");
    }
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      _showError("Name is required");
      return;
    }
    if (_gender == null) {
      _showError("Please select your gender");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("User not logged in");
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadProfileImage(_image!);
        if (imageUrl == null) {
          setState(() => _loading = false);
          return;
        }
      }

      // Save all info to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': name,
        'phone': phone,
        'gender': _gender,
        'profileUrl': imageUrl ?? '',
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      _showError("Failed to save profile");
      debugPrint("Save profile error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _uploadProfileImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("User not logged in");
        return null;
      }

      // Reference in Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('profiles/${user.uid}/profile.jpg');

      // Upload file
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});

      // Check success
      if (snapshot.state == TaskState.success) {
        final url = await ref.getDownloadURL();
        return url;
      } else {
        _showError("Upload failed: ${snapshot.state}");
        return null;
      }
    } on FirebaseException catch (e) {
      _showError("Upload failed: ${e.code}");
      return null;
    } catch (e) {
      _showError("Failed to upload profile image");
      return null;
    }
  }


  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  // ================= BUILD UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Complete Your Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Add your name, phone number, gender, and profile picture",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.purple[400],
                ),
              ),
              const SizedBox(height: 40),

              // ================= PROFILE IMAGE =================
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 68,
                      backgroundColor: Colors.purple[200],
                      backgroundImage: _image != null
                          ? FileImage(_image!) as ImageProvider
                          : (_gender == 'male'
                          ? const AssetImage('assets/images/default_profile.png')
                          : _gender == 'female'
                          ? const AssetImage('assets/images/default_pf_girl.png')
                          : null),
                      child: _image == null && _gender == null
                          ? const Icon(Icons.person, size: 68, color: Colors.white)
                          : null,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.deepPurpleAccent],
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt, size: 22, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ================= FORM =================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      hintText: "Full Name",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // ================= GENDER SELECT (moved here) =================
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: DropdownButton<String>(
                        value: _gender,
                        hint: const Text("Select Gender"),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text("Male")),
                          DropdownMenuItem(value: 'female', child: Text("Female")),
                        ],
                        onChanged: (val) => setState(() => _gender = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              ModernWowButton(
                text: "Continue",
                loading: _loading,
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.purple[700]),
        filled: true,
        fillColor: Colors.purple[50],
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
