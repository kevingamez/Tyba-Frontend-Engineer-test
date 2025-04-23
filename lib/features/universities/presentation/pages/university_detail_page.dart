import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:university_app/features/universities/domain/entities/university.dart';
import 'package:university_app/features/universities/domain/entities/university_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityDetailPage extends StatefulWidget {
  final University university;

  const UniversityDetailPage({Key? key, required this.university})
    : super(key: key);

  @override
  State<UniversityDetailPage> createState() => _UniversityDetailPageState();
}

class _UniversityDetailPageState extends State<UniversityDetailPage> {
  late UniversityDetail _universityDetail;
  final _formKey = GlobalKey<FormState>();
  final _studentCountController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _universityDetail = UniversityDetail(university: widget.university);
  }

  @override
  void dispose() {
    _studentCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _universityDetail = _universityDetail.copyWith(
            image: File(pickedFile.path),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      // Aquí podrías implementar la lógica para guardar los detalles
      // (por ejemplo, usando un repositorio o un bloc)
      int? studentCount =
          _studentCountController.text.isNotEmpty
              ? int.parse(_studentCountController.text)
              : null;

      setState(() {
        _universityDetail = _universityDetail.copyWith(
          studentCount: studentCount,
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('University details saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final university = widget.university;

    return Scaffold(
      appBar: AppBar(
        title: Text(university.name),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDetails),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // University Image
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      image:
                          _universityDetail.image != null
                              ? DecorationImage(
                                image: FileImage(_universityDetail.image!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _universityDetail.image == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo, size: 50),
                                SizedBox(height: 8),
                                Text('Tap to add image'),
                              ],
                            )
                            : null,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // University Basic Info
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildInfoRow('Name', university.name),
              _buildInfoRow('Country', university.country),
              if (university.stateProvince.isNotEmpty)
                _buildInfoRow('State/Province', university.stateProvince),
              _buildInfoRow('Alpha Two Code', university.alphaTwoCode),

              const SizedBox(height: 24),

              // University Domains
              const Text(
                'Domains',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              for (final webPage in university.webPages)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InkWell(
                    onTap: () => _launchURL(webPage),
                    child: Text(
                      webPage,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              const Text(
                'Student Count',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              TextFormField(
                controller: _studentCountController,
                decoration: const InputDecoration(
                  labelText: 'Number of Students',
                  hintText: 'Enter the number of students',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      final count = int.parse(value);
                      if (count < 0) {
                        return 'Student count must greater than 0';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveDetails,
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
