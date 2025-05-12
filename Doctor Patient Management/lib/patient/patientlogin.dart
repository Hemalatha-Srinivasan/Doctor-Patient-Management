import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import 'patientregister.dart';
import 'patientdetails.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  late Client client;
  late Account account;
  final AppwriteService _appwrite = AppwriteService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  bool obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('67ded3d9003dccc1a1e6');
    account = Account(client);
  }

  Future<void> _clearOldSessions() async {
    try {
      await account.deleteSessions();
    } catch (e) {
      print("No active session found.");
    }
  }

  Future<void> _loginPatient() async {
    setState(() => _isLoading = true);

    try {
      await _clearOldSessions();

      await account.createEmailPasswordSession(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final db = Databases(client);
      final result = await db.listDocuments(
        databaseId: '67ded3f80005c55371f9',
        collectionId: '67ded40100179828ab8e',
        queries: [
          Query.equal('email', _emailController.text),
        ],
      );

      if (result.documents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Access Denied: Not a patient")),
        );
        await account.deleteSession(sessionId: 'current');
        setState(() => _isLoading = false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient Login Successful")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientDetailsScreen()),
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
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/patientlogin.png', width: sw * 0.5),
                SizedBox(height: sh * 0.03),
                Text(
                  "Patient Login",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: sh * 0.03),

                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(fontSize: 18),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    suffixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: sh * 0.025),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(fontSize: 18),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                // Remember Me and Forgot Password
                SizedBox(height: sh * 0.01),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text("Remember me"),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Forgot Password Feature
                      },
                      child: Text("Forgot Password?",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.02),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginPatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                // Sign Up
                SizedBox(height: sh * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New user? ", style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientRegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
