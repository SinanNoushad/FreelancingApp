import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayi/FreelancerRegisterPage.dart';
import 'package:sahayi/jobmarket.dart';
import 'package:sahayi/FreelancersScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String userId; // Declare a final variable to hold the user ID

  // Constructor to accept userId
  HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  void _addProject(BuildContext context) async {
    String title = _projectTitleController.text;
    String description = _projectDescriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      try {
        String userId = widget.userId;
        await FirebaseFirestore.instance
            .collection('freelancers')
            .doc(
                userId) // This sets or creates a document with the ID of userId
            .collection('projects')
            .add({
          'title': title,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _projectTitleController.clear();
        _projectDescriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return FreelancerFieldsScreen();
      case 1:
        return JobMarketScreen(userId: widget.userId);
      case 2:
        return _buildPostProjectPage();
      case 3:
        return FreelancerRegisterPage(userId: widget.userId);
      default:
        return FreelancerFieldsScreen();
    }
  }

  Widget _buildPostProjectPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Post a New Project',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 49, 160, 240),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _projectTitleController,
                    decoration: InputDecoration(
                      labelText: 'Project Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _projectDescriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Project Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _addProject(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 16, 151, 235),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Submit Project',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('freelancers')
                .doc(widget.userId)
                .collection('projects')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No projects yet'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var projectData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            projectData['title'] ?? 'Untitled Project',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            projectData['description'] ?? 'No description',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (projectData['freelancer'] != null &&
                            projectData['freelancer'].isNotEmpty)
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('freelancers')
                                .doc(projectData['freelancer'])
                                .get(),
                            builder: (context, freelancerSnapshot) {
                              if (freelancerSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!freelancerSnapshot.hasData ||
                                  !freelancerSnapshot.data!.exists) {
                                return SizedBox.shrink();
                              }

                              var freelancerData = freelancerSnapshot.data!
                                  .data() as Map<String, dynamic>;

                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text('Project Accepted'),
                                          backgroundColor: Colors.green[100],
                                        ),
                                        SizedBox(width: 10),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: freelancerData[
                                                      'profileImageUrl'] !=
                                                  null
                                              ? NetworkImage(freelancerData[
                                                  'profileImageUrl'])
                                              : null,
                                          child: freelancerData[
                                                      'profileImageUrl'] ==
                                                  null
                                              ? Icon(Icons.person)
                                              : null,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          freelancerData['name'] ??
                                              'Unknown Freelancer',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      freelancerData['about'] ??
                                          'Unknown about',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Skills: ${(freelancerData['skills'] as List?)?.join(', ') ?? 'No skills listed'}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final Uri url = Uri.parse(
                                            'https://496gf0lz.r.ap-south-1.awstrack.me/L0/https:%2F%2Frzp.io%2Frzp%2FRQvHWsJO/1/01090194972f9860-bef4137a-3115-47bd-9d6d-d927951eeb4a-000000/wLoa7A4vMtu1yZSPuoCEd0AYCfA=191');

                                        try {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } catch (e) {
                                          print('Could not launch $url');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Could not open payment link')),
                                          );
                                        }
                                      },
                                      child: Text("Pay Now"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //  title: Text('quicker'),
      //  centerTitle: true,
      // ),
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        unselectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Freelancers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Job market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Post Project',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 66, 23, 151),
      ),
    );
  }
}
