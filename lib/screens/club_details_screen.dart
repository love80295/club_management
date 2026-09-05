import 'package:flutter/material.dart';

class ClubDetailsScreen extends StatefulWidget {
  const ClubDetailsScreen({super.key});

  @override
  State<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isJoined = false;

  // Mock club data
  final Map<String, dynamic> _clubData = {
    'id': 1,
    'name': 'Google Developer Group',
    'category': 'Technical',
    'members': 150,
    'description':
        'GDG University is a community of developers, designers, and tech enthusiasts who meet regularly to learn about Google technologies and build innovative solutions. We organize workshops, hackathons, tech talks, and coding competitions.',
    'coordinator': 'Dr. Rajesh Kumar',
    'meetingSchedule': 'Every Saturday, 4:00 PM - 6:00 PM',
    'socialLinks': {
      'instagram': '@gdg_university',
      'linkedin': 'gdg-university',
      'github': 'gdg-university',
    },
    'upcomingActivities': [
      {
        'title': 'Flutter Workshop',
        'date': '25 Aug 2026',
        'time': '10:00 AM - 4:00 PM',
        'venue': 'Computer Science Building, Room 301',
      },
      {
        'title': 'Hackathon 2026',
        'date': '15 Sep 2026',
        'time': '9:00 AM - 9:00 PM',
        'venue': 'University Auditorium',
      },
      {
        'title': 'Tech Talk: AI & ML',
        'date': '5 Sep 2026',
        'time': '2:00 PM - 5:00 PM',
        'venue': 'Science Building, Hall 101',
      },
    ],
    'pastActivities': [
      {
        'title': 'Android App Development Workshop',
        'date': '10 Jul 2026',
        'time': '10:00 AM - 5:00 PM',
        'venue': 'Computer Science Building, Room 301',
      },
      {
        'title': 'Git & GitHub Workshop',
        'date': '25 Jun 2026',
        'time': '2:00 PM - 4:00 PM',
        'venue': 'Online - Zoom',
      },
    ],
    'membersList': [
      {'name': 'Rahul Sharma', 'role': 'President', 'avatar': 'R'},
      {'name': 'Priya Patel', 'role': 'Vice President', 'avatar': 'P'},
      {'name': 'Amit Kumar', 'role': 'Technical Lead', 'avatar': 'A'},
      {'name': 'Sneha Reddy', 'role': 'Event Coordinator', 'avatar': 'S'},
      {'name': 'Vikram Singh', 'role': 'Member', 'avatar': 'V'},
      {'name': 'Anjali Gupta', 'role': 'Member', 'avatar': 'A'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _clubData['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share option coming soon!'),
                  backgroundColor: Colors.deepPurple,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('More options coming soon!'),
                  backgroundColor: Colors.deepPurple,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Club Header
          _buildClubHeader(),
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Activities'),
              Tab(text: 'Members'),
            ],
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildActivitiesTab(),
                _buildMembersTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'My Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/explore');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/myclubs');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildClubHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade400,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Club Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _clubData['name'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _clubData['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _clubData['category'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_clubData['members']} members',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Join Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isJoined = !_isJoined;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isJoined
                          ? 'Joined ${_clubData['name']} successfully! 🎉'
                          : 'Left ${_clubData['name']}',
                    ),
                    backgroundColor: _isJoined ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isJoined ? Colors.white : Colors.deepPurple,
                foregroundColor: _isJoined ? Colors.deepPurple : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isJoined ? Icons.check_circle : Icons.add_circle,
                    color: _isJoined ? Colors.deepPurple : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isJoined ? 'Joined' : 'Join Club',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _clubData['description'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // Coordinator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Club Coordinator',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _clubData['coordinator'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Meeting Schedule
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.calendar_today, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meeting Schedule',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _clubData['meetingSchedule'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Social Links with Material Icons
          const Text(
            'Connect with us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSocialChip(
                Icons.photo_camera,
                '@gdg_university',
                Colors.pink,
              ),
              _buildSocialChip(
                Icons.work,
                'gdg-university',
                Colors.blue,
              ),
              _buildSocialChip(
                Icons.code,
                'gdg-university',
                Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChip(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $label...'),
            backgroundColor: Colors.deepPurple,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Upcoming Activities
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clubData['upcomingActivities'].length,
                  itemBuilder: (context, index) {
                    final activity = _clubData['upcomingActivities'][index];
                    return _buildActivityCard(activity, isUpcoming: true);
                  },
                ),
                // Past Activities
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clubData['pastActivities'].length,
                  itemBuilder: (context, index) {
                    final activity = _clubData['pastActivities'][index];
                    return _buildActivityCard(activity, isUpcoming: false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, {required bool isUpcoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: isUpcoming ? Colors.green.shade100 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.green.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUpcoming ? 'Upcoming' : 'Past',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                activity['date'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                activity['time'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activity['venue'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registration opened! 🎉'),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Register Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clubData['membersList'].length,
      itemBuilder: (context, index) {
        final member = _clubData['membersList'][index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  member['avatar'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      member['role'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: member['role'] == 'President'
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member['role'] == 'President' ? '👑' : member['role'] == 'Member' ? '👤' : '⭐',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}