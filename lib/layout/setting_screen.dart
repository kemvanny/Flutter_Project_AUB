import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../widgets/ModernWowButton.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  bool loading = false;
  File? _imageFile;

  // ================= CLOUDINARY CONFIG =================
  final String cloudName = 'dlonqpu0r'; // Replace with your cloud name
  final String uploadPreset = 'todo-list'; // Replace with your upload preset

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // ================= UPLOAD IMAGE TO CLOUDINARY =================
  Future<String?> _uploadToCloudinary(File imageFile) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', url);

      // Add upload preset
      request.fields['upload_preset'] = uploadPreset;

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Send request
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        // Return the secure URL of uploaded image
        return jsonResponse['secure_url'];
      } else {
        print('Upload failed: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _confirmLogout() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔴 ICON
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6A6A), Color(0xFFFF3D3D)],
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // TITLE
                const Text(
                  "Logout?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // MESSAGE
                const Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                // ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, "/welcome");
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    setState(() => loading = true);
    try {
      String? imageUrl;

      // If user picked a new image, upload it to Cloudinary
      if (_imageFile != null) {
        imageUrl = await _uploadToCloudinary(_imageFile!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')));
          setState(() => loading = false);
          return;
        }
      }

      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final updateData = <String, dynamic>{};

      if (nameController.text.isNotEmpty) {
        updateData['fullName'] = nameController.text;
      }

      // Save Cloudinary URL to Firestore
      if (imageUrl != null) {
        updateData['profileUrl'] = imageUrl;
      }

      if (updateData.isNotEmpty) {
        await userDoc.update(updateData);
      }

      // Update email if changed
      if (emailController.text.isNotEmpty &&
          emailController.text != FirebaseAuth.instance.currentUser!.email) {
        await FirebaseAuth.instance.currentUser!
            .updateEmail(emailController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')));

      // Clear the local image file after successful upload
      setState(() => _imageFile = null);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= CHANGE PASSWORD =================
  Future<void> _changePassword() async {
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Change Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: "New Password"),
                  ),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: "Confirm Password"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () async {
                      if (passController.text.isEmpty ||
                          passController.text != confirmController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Passwords do not match')));
                        return;
                      }
                      try {
                        await FirebaseAuth.instance.currentUser!
                            .updatePassword(passController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password updated')));
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text("Save"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          nameController.text = data['fullName'] ?? '';
          emailController.text = FirebaseAuth.instance.currentUser!.email ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= PROFILE CARD =================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.purple[100],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!) // user picked image
                                  : (data['profileUrl'] != null &&
                                          data['profileUrl'].isNotEmpty
                                      ? NetworkImage(data[
                                          'profileUrl']) // Cloudinary uploaded image
                                      : (data['gender'] == 'male'
                                          ? const AssetImage(
                                              'assets/images/default_profile.png')
                                          : data['gender'] == 'female'
                                              ? const AssetImage(
                                                  'assets/images/default_pf_girl.png')
                                              : null)) as ImageProvider?,
                              child: _imageFile == null &&
                                      (data['profileUrl'] == null ||
                                          data['profileUrl'].isEmpty) &&
                                      (data['gender'] == null)
                                  ? const Icon(Icons.person,
                                      size: 40, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF7C3AED),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Tap photo to change",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= FORM CARD =================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _modernInput(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _modernInput(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // SAVE BUTTON
                      ModernWowButton(
                        text: "Save Profile",
                        loading: loading,
                        onPressed: _saveProfile,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= ACTIONS =================
                _actionButton(
                  icon: Icons.lock_outline,
                  label: "Change Password",
                  color: Colors.orange,
                  onTap: _changePassword,
                ),
                const SizedBox(height: 12),
                _actionButton(
                  icon: Icons.logout,
                  label: "Logout",
                  color: Colors.red,
                  onTap: _confirmLogout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _modernInput({
  required TextEditingController controller,
  required String label,
  required IconData icon,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget _actionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
