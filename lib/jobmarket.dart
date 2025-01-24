import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JobMarketScreen extends StatefulWidget {
  final String userId;
  JobMarketScreen({Key? key, required this.userId}) : super(key: key);
  @override
  _JobMarketScreenState createState() => _JobMarketScreenState();
}

class _JobMarketScreenState extends State<JobMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Market'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collectionGroup('projects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No projects available'));
          }

          // Filter projects based on search query
          var filteredProjects = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['title']
                    .toString()
                    .toLowerCase()
                    .contains(_searchQuery) ||
                data['description']
                    .toString()
                    .toLowerCase()
                    .contains(_searchQuery);
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              var projectData =
                  filteredProjects[index].data() as Map<String, dynamic>;
              var projectId = filteredProjects[index].id;
              var freelancerId =
                  filteredProjects[index].reference.parent.parent?.id;

              return _buildProjectCard(projectData, projectId, freelancerId);
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> projectData, String projectId,
      String? freelancerId) {
    String userId = widget.userId;
    return FutureBuilder<DocumentSnapshot>(
      future: freelancerId != null
          ? FirebaseFirestore.instance
              .collection('freelancers')
              .doc(freelancerId)
              .get()
          : null,
      builder: (context, freelancerSnapshot) {
        if (projectData['freelancer'] != null &&
            projectData['freelancer'].isNotEmpty) {
          return SizedBox.shrink(); // Return an empty widget to hide the tile
        }
        String freelancerName = 'Unknown Freelancer';
        String freelancerProfileImage = '';

        if (freelancerSnapshot.hasData &&
            freelancerSnapshot.data?.exists == true) {
          var freelancerData =
              freelancerSnapshot.data!.data() as Map<String, dynamic>?;
          freelancerName = freelancerData?['name'] ?? freelancerName;
          freelancerProfileImage = freelancerData?['profileImageUrl'] ?? '';
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Freelancer Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: freelancerProfileImage.isNotEmpty
                          ? NetworkImage(freelancerProfileImage)
                          : null,
                      child: freelancerProfileImage.isEmpty
                          ? Icon(Icons.person, size: 20)
                          : null,
                    ),
                    SizedBox(width: 10),
                    Text(
                      freelancerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Project Title
                Text(
                  projectData['title'] ?? 'Untitled Project',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 8),

                // Project Description
                Text(
                  projectData['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),

                // Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTimestamp(projectData['timestamp']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('freelancers')
                            .doc(freelancerId)
                            .collection('projects')
                            .doc(projectId) // Use the existing project ID
                            .set({
                          'freelancer':
                              userId, // Add userId to the project document
                        }, SetOptions(merge: true));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'accept project',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final DateTime date = timestamp.toDate();
    return date.toString();
  }
}
