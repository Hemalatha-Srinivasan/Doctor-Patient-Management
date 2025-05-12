import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final AppwriteService _appwrite = AppwriteService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _appwrite.registerUser(
        _emailController.text,
        _passwordController.text,
        {
          'username': _usernameController.text,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'hospital': _hospitalController.text,
          'city': _cityController.text,
          'country': _countryController.text,
          'age': _ageController.text,
          'gender': _genderController.text,
        },
        'patients',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient Registration Successful")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Registration"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.02),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/images/patient.png',
                width: sw * 0.4,
              ),
              SizedBox(height: sh * 0.015),
              _buildTextField(
                  "Username", Icons.person, _usernameController, sw),
              _buildTextField(
                  "First Name", Icons.person, _firstNameController, sw),
              _buildTextField(
                  "Last Name", Icons.person, _lastNameController, sw),
              _buildTextField(
                  "Hospital", Icons.local_hospital, _hospitalController, sw),
              _buildTextField("City", Icons.location_city, _cityController, sw),
              _buildTextField("Country", Icons.flag, _countryController, sw),
              _buildTextField("Age", Icons.cake, _ageController, sw,
                  isNumber: true),
              _buildTextField("Gender", Icons.wc, _genderController, sw),
              _buildTextField("Email", Icons.email, _emailController, sw,
                  isEmail: true),
              _buildTextField("Password", Icons.lock, _passwordController, sw,
                  isPassword: true),
              SizedBox(height: sh * 0.025),
              SizedBox(
                width: double.infinity,
                height: sh * 0.065,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Register",
                          style: TextStyle(
                            fontSize: sw * 0.045,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
    double sw, {
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isNumber
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: sw * 0.04),
          prefixIcon: Icon(icon, size: sw * 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: TextStyle(fontSize: sw * 0.042),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          if (isEmail &&
              !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value)) {
            return "Enter a valid email";
          }
          if (isNumber && int.tryParse(value) == null) {
            return "Enter a valid number";
          }
          if (isPassword && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }
}
