import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Register"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _buildLogo(),
          SizedBox(height: 40),
          _buildResgisterForm(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Text(
        "PLANME",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.indigo.shade700,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildResgisterForm() {
    return Column(
      children: [
        Text(
          "Create your account!!",
          style: TextStyle(
            color: Color(0xff737373),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 30),
        _buildTxtfieldItem(txt: "Full Name"),
        SizedBox(height: 25),
        _buildTxtfieldItem(txt: "Email"),
        SizedBox(height: 25),
        _buildTxtfieldItem(txt: "Password"),
        SizedBox(height: 25),
        _buildTxtfieldItem(txt: "Confirm Password"),
        SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to next screen
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9B5F0),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
        Text(
          "Or sign up with",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xff737373),
          ),
        ),
      ],
    );
  }

  Widget _buildTxtfieldItem({required String txt}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: txt,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
