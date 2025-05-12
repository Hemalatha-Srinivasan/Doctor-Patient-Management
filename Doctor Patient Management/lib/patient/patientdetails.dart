import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'dart:io';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final List<Map<String, dynamic>> previousImages = [];
  final Map<String, bool> weeklyProgress = {
    "Sun": false,
    "Mon": false,
    "Tue": false,
    "Wed": false,
    "Thu": false,
    "Fri": false,
    "Sat": false,
  };

  final String bucketId = "67ded430003419eba777";
  late Storage _storage;
  late Account _account;
  String patientName = "Loading...";
  String patientId = "";
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    Client client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('67ded3d9003dccc1a1e6');
    _storage = Storage(client);
    _account = Account(client);

    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
      final models.User response = await _account.get();
      setState(() {
        patientName = response.name;
        patientId = response.$id;
      });
      await _fetchPreviousImages();
    } catch (e) {
      print("Error fetching patient details: $e");
    }
  }

  Future<void> _fetchPreviousImages() async {
    try {
      final response = await _storage.listFiles(bucketId: bucketId);
      setState(() {
        previousImages.clear();
        for (var file in response.files) {
          if (file.name.startsWith(patientId)) {
            String imageUrl =
                'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/${file.$id}/view?project=67ded3d9003dccc1a1e6';
            previousImages.add({
              "imageId": file.$id,
              "imageUrl": imageUrl,
              "description": "Uploaded on ${file.$createdAt}",
            });
          }
        }
      });
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    try {
      setState(() => isUploading = true);

      File imageFile = File(pickedFile.path);
      if (!await imageFile.exists()) {
        throw Exception("Captured image not found.");
      }

      String fileName =
          "${patientId}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final file = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imageFile.path, filename: fileName),
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      String imageUrl =
          'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/${file.$id}/view?project=67ded3d9003dccc1a1e6';

      setState(() {
        previousImages.add({
          "imageId": file.$id,
          "imageUrl": imageUrl,
          "description": "Uploaded on ${DateTime.now()}",
        });

        String today = [
          "Sun",
          "Mon",
          "Tue",
          "Wed",
          "Thu",
          "Fri",
          "Sat"
        ][DateTime.now().weekday % 7];
        weeklyProgress[today] = true;
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        await _uploadImage(pickedFile);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text("Select Image Source",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text("Camera"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.photo_library),
                    label: Text("Gallery"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount = screenWidth > 600 ? 3 : 2;

        return Scaffold(
          appBar: AppBar(
            title: Text("Patient Details"),
            backgroundColor: const Color.fromARGB(255, 52, 126, 252),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 30),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text("ID: $patientId",
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text("Daily Progress",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: weeklyProgress.keys.map((day) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Text(day, style: TextStyle(fontSize: 16)),
                            Icon(
                              weeklyProgress[day]!
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: weeklyProgress[day]!
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: isUploading ? null : _showImageSourceDialog,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Take New Photo"),
                  ),
                ),
                if (isUploading) ...[
                  SizedBox(height: 10),
                  Center(child: CircularProgressIndicator()),
                ],
                SizedBox(height: 20),
                Text(
                  "Previous Images",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                previousImages.isEmpty
                    ? Text("No previous images available.")
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: previousImages.length,
                        itemBuilder: (context, index) {
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  previousImages[index]['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.black54,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 6),
                                    child: Text(
                                      previousImages[index]['description'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
