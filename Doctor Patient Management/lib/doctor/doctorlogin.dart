import 'package:appwrite/appwrite.dart';
import 'package:dpm/doctor/doctorpatientdetails.dart';
import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import 'doctorregister.dart';

class Doctorloginscreen extends StatefulWidget {
  const Doctorloginscreen({super.key});

  @override
  State<Doctorloginscreen> createState() => _DoctorloginscreenState();
}

class _DoctorloginscreenState extends State<Doctorloginscreen> {
  final _appwrite = AppwriteService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberme = false;
  bool obscurepassword = true;
  bool _isLoading = false;

  Future<void> _loginDoctor() async {
    setState(() => _isLoading = true);

    try {
      await _appwrite.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final doctorData = await _appwrite.databases.listDocuments(
        databaseId: '67ded3f80005c55371f9',
        collectionId: '67ded414000a1664b9d3',
        queries: [Query.equal('email', _emailController.text.trim())],
      );

      if (doctorData.documents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Access Denied: Not a Doctor")),
        );
        await _appwrite.account.deleteSession(sessionId: 'current');
        setState(() => _isLoading = false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor Login Successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorPatientDetails(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: sh),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(height: sh * 0.05),

                  // Image
                  Center(
                    child: Image.asset(
                      'assets/images/doctorlogin.png',
                      width: sw * 0.6,
                    ),
                  ),
                  SizedBox(height: sh * 0.02),

                  const Text(
                    "Doctor Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: sh * 0.03),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: const TextStyle(fontSize: 18),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      suffixIcon: const Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: sh * 0.02),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: obscurepassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(fontSize: 18),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurepassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurepassword = !obscurepassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.01),

                  // Remember Me + Forgot Password
                  Row(
                    children: [
                      Checkbox(
                        value: rememberme,
                        onChanged: (value) {
                          setState(() {
                            rememberme = value ?? false;
                          });
                        },
                      ),
                      const Text("Remember me"),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.02),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_emailController.text.isEmpty ||
                            _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Please enter email and password")),
                          );
                        } else {
                          _loginDoctor();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                  SizedBox(height: sh * 0.02),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New user? ", style: TextStyle(fontSize: 16)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DoctorRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
