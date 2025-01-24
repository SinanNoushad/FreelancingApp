import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FreelancerFieldsScreen extends StatefulWidget {
  @override
  _FreelancerFieldsScreenState createState() => _FreelancerFieldsScreenState();
}

class FreelancerFieldsData {
  static List<String> commonFields = [
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
}

class _FreelancerFieldsScreenState extends State<FreelancerFieldsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _displayedFields = FreelancerFieldsData.commonFields;

  void _filterFields(String query) {
    setState(() {
      _displayedFields = FreelancerFieldsData.commonFields
          .where((field) => field.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 116, 183, 241),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "What you are looking for?",
                    style: TextStyle(
                        fontSize: 50,
                        color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search fields or skills...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: _filterFields,
                  ),
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _displayedFields.length,
              itemBuilder: (context, index) {
                // Convert field name to lowercase and replace spaces with underscores
                String imageName = _displayedFields[index].replaceAll(' ', '_');

                // List of writing-specific fields that use default image
                List<String> writingFields = [
                  'Article_Writer',
                  'Blog_Writer',
                  'eBook_Writer',
                  'Fiction_Writer',
                  'Web_Content_Writer',
                  'Copywriter',
                  'Writing_Translator',
                  'Editor',
                  'Proofreader',
                  'Press_Release_Writer',
                  'Ghost_Writer',
                  'Legal_Writer',
                  'Resume_&_Cover_Letter_Writer'
                ];

                // Use default image for writing fields
                if (writingFields.contains(imageName)) {
                  imageName = imageName; // This line is actually redundant.
                } else {
                  // Keep the original imageName if not in writingFields
                  // Create a Random object
                  Random random = Random();

                  // Select a random index from writingFields
                  int randomIndex = random.nextInt(writingFields.length);

                  // Assign a random value from writingFields
                  imageName = writingFields[randomIndex];
                }
                print("midhun : $imageName");
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FreelancersListScreen(
                            selectedField: _displayedFields[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.1), // Shadow color
                            spreadRadius: 2, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset: Offset(
                                0, 3), // Changes the position of the shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 125,
                            child: Image.asset(
                              'assets/images/$imageName.jpeg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _displayedFields[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FreelancersListScreen extends StatefulWidget {
  final String selectedField;

  const FreelancersListScreen({Key? key, required this.selectedField})
      : super(key: key);

  @override
  _FreelancersListScreenState createState() => _FreelancersListScreenState();
}

class _FreelancersListScreenState extends State<FreelancersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Freelancers in ${widget.selectedField}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search freelancers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('freelancers')
                  .where('skills', arrayContains: widget.selectedField)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No freelancers found'));
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['name']
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (data['skills'] as List).any((skill) => skill
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()));
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var freelancerData =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(freelancerData['profileImageUrl']),
                        ),
                        title: Text(
                          freelancerData['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Skills: ${(freelancerData['skills'] as List).join(', ')}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'About: ${freelancerData['about']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
