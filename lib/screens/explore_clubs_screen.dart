import 'package:flutter/material.dart';

class ExploreClubsScreen extends StatefulWidget {
  const ExploreClubsScreen({super.key});

  @override
  State<ExploreClubsScreen> createState() => _ExploreClubsScreenState();
}

class _ExploreClubsScreenState extends State<ExploreClubsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Technical',
    'Cultural',
    'Sports',
    'Academic',
    'Arts',
  ];

  final List<Map<String, dynamic>> _allClubs = [
    {
      'id': 1,
      'name': 'Google Developer Group',
      'category': 'Technical',
      'members': 150,
      'description': 'Learn, connect, and grow as a developer',
      'isJoined': true,
    },
    {
      'id': 2,
      'name': 'Music Club',
      'category': 'Cultural',
      'members': 85,
      'description': 'For music lovers and performers',
      'isJoined': false,
    },
    {
      'id': 3,
      'name': 'Robotics Club',
      'category': 'Technical',
      'members': 120,
      'description': 'Build robots and compete',
      'isJoined': false,
    },
    {
      'id': 4,
      'name': 'Photography Club',
      'category': 'Cultural',
      'members': 95,
      'description': 'Capture the moment',
      'isJoined': false,
    },
    {
      'id': 5,
      'name': 'Sports Club',
      'category': 'Sports',
      'members': 200,
      'description': 'Stay active and healthy',
      'isJoined': true,
    },
    {
      'id': 6,
      'name': 'AI Club',
      'category': 'Technical',
      'members': 110,
      'description': 'Explore Artificial Intelligence',
      'isJoined': false,
    },
    {
      'id': 7,
      'name': 'Drama Club',
      'category': 'Arts',
      'members': 70,
      'description': 'Acting and theatre performances',
      'isJoined': false,
    },
    {
      'id': 8,
      'name': 'Debate Society',
      'category': 'Academic',
      'members': 60,
      'description': 'Sharpen your debating skills',
      'isJoined': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredClubs {
    return _allClubs.where((club) {
      final matchesSearch = club['name']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          club['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Clubs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
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
        child: Column(
          children: [
            // Search Bar - Compact
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 1,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Search clubs...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter Chips - Compact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.deepPurple.shade100,
                        checkmarkColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.deepPurple : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Club Count and View Toggle - Compact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredClubs.length} Clubs Found',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Grid View',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Clubs Grid - Takes remaining space
            Expanded(
              child: _filteredClubs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No clubs found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: _filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = _filteredClubs[index];
                        return _buildClubCard(club);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
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
            // Already on Explore
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/myclubs');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/clubdetails');
      },
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Club Logo/Icon
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: Text(
                    club['name'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ),
            // Club Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${club['members']}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          club['isJoined'] = !club['isJoined'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              club['isJoined']
                                  ? 'Joined ${club['name']}!'
                                  : 'Left ${club['name']}',
                            ),
                            backgroundColor: club['isJoined'] ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: club['isJoined'] ? Colors.green : Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 28),
                      ),
                      child: Text(
                        club['isJoined'] ? 'Joined' : 'Join',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
}