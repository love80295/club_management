import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../services/club_service.dart';

class MyClubsScreen extends StatefulWidget {
  const MyClubsScreen({super.key});

  @override
  State<MyClubsScreen> createState() => _MyClubsScreenState();
}

class _MyClubsScreenState extends State<MyClubsScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

  List<Club> _myClubs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyClubs();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD MY CLUBS
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadMyClubs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ClubService.getMyClubs();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _myClubs = result['clubs'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Failed to load clubs';
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LEAVE CLUB
  // ═══════════════════════════════════════════════════════════
  Future<void> _leaveClub(Club club) async {
    final confirm = await _showLeaveConfirmation(club);
    if (confirm != true) return;

    setState(() => _isLoading = true);

    final result = await ClubService.leaveClub(club.id);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackBar('Left ${club.name}', Colors.orange);
      _loadMyClubs();
    } else {
      setState(() => _isLoading = false);
      _showSnackBar(result['message'] ?? 'Failed to leave', Colors.red);
    }
  }

  Future<bool?> _showLeaveConfirmation(Club club) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Club'),
        content: Text('Are you sure you want to leave "${club.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTERED & SORTED
  // ═══════════════════════════════════════════════════════════
  List<Club> get _filteredClubs {
    var clubs = List<Club>.from(_myClubs);

    // Sort
    if (_selectedSort == 'Recent') {
      clubs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Alphabetical') {
      clubs.sort((a, b) => a.name.compareTo(b.name));
    }

    return clubs;
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyClubs,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/explore');
            },
            tooltip: 'Discover Clubs',
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: _loadMyClubs,
                    color: Colors.deepPurple,
                    child: _filteredClubs.isEmpty
                        ? _buildEmptyState()
                        : CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: _buildStatsSummary(),
                              ),
                              SliverToBoxAdapter(
                                child: _buildFilterSortBar(),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return _buildClubCard(_filteredClubs[index]);
                                  },
                                  childCount: _filteredClubs.length,
                                ),
                              ),
                            ],
                          ),
                  ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATS SUMMARY
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsSummary() {
    final totalMembers = _myClubs.fold<int>(
      0,
      (sum, club) => sum + club.memberCount,
    );

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
            color: Colors.deepPurple.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Clubs',
            _myClubs.length.toString(),
            Icons.group,
          ),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildStatItem(
            'Members',
            totalMembers.toString(),
            Icons.people,
          ),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildStatItem(
            'Active',
            _myClubs.length.toString(),
            Icons.check_circle,
          ),
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

  // ═══════════════════════════════════════════════════════════
  // FILTER / SORT BAR
  // ═══════════════════════════════════════════════════════════
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
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
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
                    DropdownMenuItem(
                        value: 'Recent', child: Text('Most Recent')),
                    DropdownMenuItem(
                        value: 'Alphabetical', child: Text('A-Z Order')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSort = value!);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CLUB CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildClubCard(Club club) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/clubdetails',
          arguments: club.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              spreadRadius: 2,
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  club.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(club.category)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          club.category,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: _getCategoryColor(club.category),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.people, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${club.memberCount}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Leave button
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              tooltip: 'Leave Club',
              onPressed: () => _leaveClub(club),
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

  // ═══════════════════════════════════════════════════════════
  // EMPTY & ERROR STATES
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.group_off, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'No Clubs Joined Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
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
                  Navigator.pushReplacementNamed(context, '/explore');
                },
                icon: const Icon(Icons.explore),
                label: const Text('Explore Clubs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadMyClubs,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return BottomNavigationBar(
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
          // Already here
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
    );
  }
}