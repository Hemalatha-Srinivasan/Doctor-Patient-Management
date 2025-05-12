import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class DoctorPatientDetails extends StatefulWidget {
  const DoctorPatientDetails({super.key});

  @override
  _DoctorPatientDetailsState createState() => _DoctorPatientDetailsState();
}

class _DoctorPatientDetailsState extends State<DoctorPatientDetails> {
  late Client _client;
  late Databases _database;
  late Storage _storage;

  List<Map<String, dynamic>> patients = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    _fetchPatients();
  }

  void _initializeAppwrite() {
    _client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('67ded3d9003dccc1a1e6');

    _database = Databases(_client);
    _storage = Storage(_client);
  }

  Future<void> _fetchPatients() async {
    try {
      final result = await _database.listDocuments(
        databaseId: '67ded3f80005c55371f9',
        collectionId: '67ded40100179828ab8e',
      );

      setState(() {
        patients = result.documents.map((doc) {
          return {
            "id": doc.$id,
            "name": doc.data['first_name'] ?? 'Unknown Name',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching patients: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToPatientPage(BuildContext context, String name, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PatientDetailsPage(patientName: name, patientId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor's Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            patient["name"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text("ID: ${patient["id"]}"),
                          onTap: () => _navigateToPatientPage(
                            context,
                            patient["name"],
                            patient["id"],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class PatientDetailsPage extends StatefulWidget {
  final String patientName;
  final String patientId;

  const PatientDetailsPage({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late Client _client;
  late Storage _storage;

  String? latestImageUrl;
  bool _isLoading = true;

  static const String bucketId = '67ded430003419eba777';

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    _fetchLatestImage();
  }

  void _initializeAppwrite() {
    _client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('67ded3d9003dccc1a1e6');

    _storage = Storage(_client);
  }

  Future<void> _fetchLatestImage() async {
    try {
      final result = await _storage.listFiles(bucketId: bucketId);
      final filtered = result.files
          .where((file) => file.name.startsWith(widget.patientId))
          .toList();

      if (filtered.isNotEmpty) {
        filtered.sort((a, b) => b.$createdAt.compareTo(a.$createdAt));
        final fileId = filtered.first.$id;

        setState(() {
          latestImageUrl =
              'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=67ded3d9003dccc1a1e6';
          _isLoading = false;
        });
      } else {
        setState(() {
          latestImageUrl = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching image: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double sh = MediaQuery.of(context).size.height;
    double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${widget.patientName}",
                style: TextStyle(fontSize: sw * 0.045)),
            Text("Patient ID: ${widget.patientId}",
                style: TextStyle(fontSize: sw * 0.045)),
            SizedBox(height: sh * 0.03),
            Text(
              "Latest Wound Image",
              style:
                  TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: sh * 0.015),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : latestImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          latestImageUrl!,
                          width: sw,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Text("No image uploaded",
                        style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
