import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final AppwriteService _appwrite = AppwriteService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerDoctor() async {
    setState(() => _isLoading = true);

    try {
      await _appwrite.registerUser(
        _emailController.text,
        _passwordController.text,
        {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'hospital_name': _hospitalController.text,
          'designation': _designationController.text,
          'city': _cityController.text,
          'email': _emailController.text,
        },
        'doctors',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor Registration Successful")),
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
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Registration")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.08,
                vertical: sh * 0.03,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      sw > 600 ? 500 : sw, // limits form width on large screens
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/doctor.jpg', width: 250),
                    const SizedBox(height: 15),
                    const Text(
                      "Doctor Registration",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                        "Username", Icons.person, _usernameController),
                    const SizedBox(height: 15),
                    _buildInputField(
                        "First Name", Icons.person, _firstNameController),
                    const SizedBox(height: 15),
                    _buildInputField(
                        "Last Name", Icons.person, _lastNameController),
                    const SizedBox(height: 15),
                    _buildInputField("Hospital Name", Icons.local_hospital,
                        _hospitalController),
                    const SizedBox(height: 15),
                    _buildInputField(
                        "Designation", Icons.work, _designationController),
                    const SizedBox(height: 15),
                    _buildInputField(
                        "City", Icons.location_city, _cityController),
                    const SizedBox(height: 15),
                    _buildInputField(
                      "Email",
                      Icons.email,
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      "Password",
                      Icons.lock,
                      _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerDoctor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    String hintText,
    IconData icon,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hintText,
        suffixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
