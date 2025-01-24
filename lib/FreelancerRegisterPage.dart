import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FreelancerRegisterPage extends StatefulWidget {
  final String userId; // Declare a final variable to hold the user ID

  // Constructor to accept userId
  FreelancerRegisterPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FreelancerRegisterPageState createState() => _FreelancerRegisterPageState();
}

class _FreelancerRegisterPageState extends State<FreelancerRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  File? _profileImage;
  XFile? pickedFile;
  bool _isUploading = false;
  bool edit = true;
  final picker = ImagePicker();
  String? profileImageUrl;
  Map<String, dynamic>? _existingProfile;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  final List<String> _allSkills = [
    'Article Writer',
    'Blog Writer',
    'eBook Writer',
    'Fiction Writer',
    'Web Content Writer',
    'Copywriter',
    'Writing Translator',
    'Editor',
    'Proofreader',
    'Press Release Writer',
    'Ghost Writer',
    'Legal Writer',
    'Resume & Cover Letter Writer',
    'Product Description Writer',
    'Transcription Writer',
    'Technical Writer',
    'Guest Writer',
    'Academic Writing',
    'Logo Designer',
    'Photoshop Editor',
    'Website Mockup Designer',
    'Photo Editor',
    'Photo Retouching',
    'Graphic/Poster Designer',
    'Icon Designer',
    'Book Cover Designer',
    'T-Shirt Designer',
    'Infographic Designer',
    'CAD Designer',
    'Vector Designer',
    'Cartoon Artist',
    'Banner/Ad Designer',
    'Wedding Album Designer',
    'Sketch Artist',
    'Digital Artist',
    'Vector Illustrator',
    'Print Designer',
    'Concept Artist',
    'Oil Painter',
    'Flyer Designer',
    'Brochure Designer',
    'Front-End Developer',
    'Back-End Developer',
    'UX/UI Designer',
    'Plugin Developer',
    'Explainer Video Animator',
    '3D Model Designer',
    'Social Media Manager',
    'Marketing Strategist',
    'Lead Generator',
    'Virtual Assistant',
    'Data Entry Specialist',
    'Customer Support Representative',
    'Live Chat Agent',
    'Project Manager',
    'Bookkeeper',
    'Technical Assistant',
    'Voice-Over Artist',
    'Audio Editor',
    'Music Composer',
    'Podcast Producer',
    'Email Outreach Specialist',
    'Online Advertising Expert',
    'Presentation Designer',
    'Content Strategist',
    'Market Research Analyst',
    'Branding Consultant',
    'Outdoor Advertising Specialist',
    'Freelance Photographer',
    'YouTube Thumbnail Artist',
    'User Testing Specialist'
  ];

  List<String> _filteredSkills = [];
  List<String> _selectedSkills = [];

  @override
  void initState() {
    super.initState();
    _filteredSkills = _allSkills;
    _searchController.addListener(_filterSkills);
    _fetchExistingProfile();
  }

  Future<void> _fetchExistingProfile() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('freelancers')
          .doc(widget.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _existingProfile = doc.data() as Map<String, dynamic>;
        });
        if (_existingProfile?['name'] != null) {
          edit = false;
          _fetchProfileData();
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('freelancers')
          .doc(widget.userId)
          .get();

      setState(() {
        _profileData = docSnapshot.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching profile: $e');
    }
  }

  void _filterSkills() {
    setState(() {
      _filteredSkills = _allSkills
          .where((skill) => skill
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile!.path);
      }
    });
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    try {
      // Check if widget is still mounted before async operations
      if (!mounted) return null;

      int fileSize = await _profileImage!.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image too large. Max 5MB allowed.')),
          );
        }
        return null;
      }

      String fileName =
          '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_pictures/$fileName');

      UploadTask uploadTask = storageReference.putFile(
          _profileImage!,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'user_id': widget.userId},
          ));

      // Wait for upload to complete
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
      return null;
    }
  }

  void _registerFreelancer(BuildContext context) async {
    String userId = widget.userId;
    String name = _nameController.text;
    String about = _aboutController.text;
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload a profile picture'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (name.isNotEmpty && _selectedSkills.isNotEmpty) {
      try {
        edit = false;
        // Upload profile picture if selected
        profileImageUrl = await _uploadProfileImage();

        // Create freelancer document with profile data
        await FirebaseFirestore.instance
            .collection('freelancers')
            .doc(userId)
            .set({
          'name': name,
          'about': about,
          'skills': _selectedSkills,
          'profileImageUrl': profileImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Use merge option

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Freelancer registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _aboutController.clear();
        // Reset form
        _nameController.clear();
        if (mounted) {
          setState(() {
            _selectedSkills.clear();
            _profileImage = null;
            _isUploading = false;
          });
        }
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering freelancer: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter name and select at least one skill'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (edit) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Freelancer Registration'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SizedBox(
              height: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey[600])
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'About You',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Tell us about your professional experience...',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Skills',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredSkills.length,
                      itemBuilder: (context, index) {
                        final skill = _filteredSkills[index];
                        return CheckboxListTile(
                          title: Text(skill),
                          value: _selectedSkills.contains(skill),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedSkills.add(skill);
                              } else {
                                _selectedSkills.remove(skill);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Selected Skills: ${_selectedSkills.join(", ")}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : () => _registerFreelancer(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 73, 196, 244),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isUploading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Register',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 245, 245, 245)),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      if (_isLoading) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (_profileData == null) {
        return Scaffold(
          body: Center(child: Text('No profile found')),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      edit = true;
                    });
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileData?['profileImageUrl'] != null
                          ? NetworkImage(_profileData?['profileImageUrl'])
                          : null,
                      child: _profileData?['profileImageUrl'] == null
                          ? Icon(Icons.person, size: 60)
                          : null,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _profileData?['name'] ?? 'Unnamed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                title: Text(_profileData?['name'] ?? 'Profile'),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text("about"),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 240, 236, 245),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _profileData?['about'] ?? 'about',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_profileData?['skills'] as List<dynamic> ?? [])
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.deepPurple.shade50,
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Profile Created',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "last edited :${_profileData?['timestamp']}",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    }
  }
}
