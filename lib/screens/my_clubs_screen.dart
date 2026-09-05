import 'package:flutter/material.dart';

class MyClubsScreen extends StatefulWidget {
  const MyClubsScreen({super.key});

  @override
  State<MyClubsScreen> createState() => _MyClubsScreenState();
}

class _MyClubsScreenState extends State<MyClubsScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

  // Mock joined clubs data
  final List<Map<String, dynamic>> _joinedClubs = [
    {
      'id': 1,
      'name': 'Google Developer Group',
      'category': 'Technical',
      'members': 150,
      'role': 'Member',
      'upcomingActivities': 3,
      'joinedDate': '15 Jan 2026',
      'isActive': true,
    },
    {
      'id': 2,
      'name': 'Music Club',
      'category': 'Cultural',
      'members': 85,
      'role': 'Member',
      'upcomingActivities': 1,
      'joinedDate': '20 Feb 2026',
      'isActive': true,
    },
    {
      'id': 3,
      'name': 'Robotics Club',
      'category': 'Technical',
      'members': 120,
      'role': 'Admin',
      'upcomingActivities': 5,
      'joinedDate': '10 Mar 2026',
      'isActive': true,
    },
    {
      'id': 4,
      'name': 'Photography Club',
      'category': 'Cultural',
      'members': 95,
      'role': 'Member',
      'upcomingActivities': 2,
      'joinedDate': '5 Apr 2026',
      'isActive': false,
    },
  ];

  // Get filtered clubs
  List<Map<String, dynamic>> get _filteredClubs {
    var clubs = _joinedClubs.where((club) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Active') return club['isActive'] == true;
      if (_selectedFilter == 'Inactive') return club['isActive'] == false;
      return true;
    }).toList();

    if (_selectedSort == 'Recent') {
      clubs.sort((a, b) => b['joinedDate'].compareTo(a['joinedDate']));
    } else if (_selectedSort == 'Alphabetical') {
      clubs.sort((a, b) => a['name'].compareTo(b['name']));
    }

    return clubs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Clubs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/explore');
            },
            tooltip: 'Discover New Clubs',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Stats Summary
            SliverToBoxAdapter(
              child: _buildStatsSummary(),
            ),
            // Filter and Sort
            SliverToBoxAdapter(
              child: _buildFilterSortBar(),
            ),
            // Club List
            if (_filteredClubs.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final club = _filteredClubs[index];
                    return _buildClubCard(club);
                  },
                  childCount: _filteredClubs.length,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'My Clubs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/explore');
          } else if (index == 2) {
            // Already on My Clubs
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildStatsSummary() {
    final activeClubs = _joinedClubs.where((club) => club['isActive'] == true).length;
    final totalMembers = _joinedClubs.fold<int>(0, (sum, club) => sum + (club['members'] as int));
    final totalActivities = _joinedClubs.fold<int>(
        0, (sum, club) => sum + (club['upcomingActivities'] as int));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Clubs', '$activeClubs/${_joinedClubs.length}', Icons.group),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildStatItem('Members', totalMembers.toString(), Icons.people),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildStatItem('Activities', totalActivities.toString(), Icons.event),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildFilterSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: const Icon(Icons.filter_list, size: 18),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Clubs')),
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSort,
                  icon: const Icon(Icons.sort, size: 18),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Recent', child: Text('Most Recent')),
                    DropdownMenuItem(value: 'Alphabetical', child: Text('A-Z Order')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/clubdetails');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 6,
            ),
          ],
          border: club['isActive']
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            // Club Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: club['isActive'] ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  club['name'][0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: club['isActive'] ? Colors.deepPurple : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Club Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          club['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (club['role'] == 'Admin')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      if (!club['isActive'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(club['category']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          club['category'],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: _getCategoryColor(club['category']),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.people, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${club['members']}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.event, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${club['upcomingActivities']}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: club['isActive'] ? Colors.deepPurple : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Technical':
        return Colors.blue;
      case 'Cultural':
        return Colors.purple;
      case 'Sports':
        return Colors.green;
      case 'Academic':
        return Colors.orange;
      case 'Arts':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No Clubs Joined Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover and join clubs that match your interests',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/explore');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Clubs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}