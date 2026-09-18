import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../services/club_service.dart';

class ExploreClubsScreen extends StatefulWidget {
  const ExploreClubsScreen({super.key});

  @override
  State<ExploreClubsScreen> createState() => _ExploreClubsScreenState();
}

class _ExploreClubsScreenState extends State<ExploreClubsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _showGrid = true;

  List<Club> _clubs = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = [
    'All',
    'Technical',
    'Cultural',
    'Sports',
    'Academic',
    'Arts',
  ];

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD CLUBS FROM API
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadClubs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ClubService.getAllClubs(
      search: _searchController.text.trim(),
      category: _selectedCategory,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _clubs = result['clubs'] ?? [];
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
  // JOIN / LEAVE CLUB
  // ═══════════════════════════════════════════════════════════
  Future<void> _toggleJoin(Club club) async {
    setState(() => _isLoading = true);

    final result = club.isJoined
        ? await ClubService.leaveClub(club.id)
        : await ClubService.joinClub(club.id);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackBar(
        result['message'] ??
            (club.isJoined
                ? 'Left ${club.name}'
                : 'Joined ${club.name}!'),
        club.isJoined ? Colors.orange : Colors.green,
      );
      await _loadClubs();
    } else {
      setState(() => _isLoading = false);
      _showSnackBar(result['message'] ?? 'Action failed', Colors.red);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SNACKBAR
  // ═══════════════════════════════════════════════════════════
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
  // BUILD
  // ═══════════════════════════════════════════════════════════
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
            icon: Icon(_showGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _showGrid = !_showGrid),
            tooltip: _showGrid ? 'List View' : 'Grid View',
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
            // ═══════════════════════════════════════════════
            // SEARCH BAR
            // ═══════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.08),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _loadClubs(),
                  decoration: InputDecoration(
                    hintText: 'Search clubs...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _loadClubs();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════
            // CATEGORY FILTER CHIPS
            // ═══════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade700,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                          _loadClubs();
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.deepPurple.shade100,
                        checkmarkColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ═══════════════════════════════════════════════
            // COUNT
            // ═══════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_clubs.length} Clubs Found',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════
            // CLUBS LIST/GRID
            // ═══════════════════════════════════════════════
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.deepPurple),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _clubs.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadClubs,
                              color: Colors.deepPurple,
                              child: _showGrid
                                  ? _buildGridView()
                                  : _buildListView(),
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GRID VIEW
  // ═══════════════════════════════════════════════════════════
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _clubs.length,
      itemBuilder: (context, index) => _buildClubGridCard(_clubs[index]),
    );
  }

  Widget _buildClubGridCard(Club club) {
    return GestureDetector(
      onTap: () => _openClubDetails(club),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo area
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
                    club.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(club.category).withValues(alpha: 0.2),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${club.memberCount}',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _toggleJoin(club),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            club.isJoined ? Colors.green : Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 28),
                      ),
                      child: Text(
                        club.isJoined ? 'Joined' : 'Join',
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

  // ═══════════════════════════════════════════════════════════
  // LIST VIEW
  // ═══════════════════════════════════════════════════════════
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: _clubs.length,
      itemBuilder: (context, index) => _buildClubListCard(_clubs[index]),
    );
  }

  Widget _buildClubListCard(Club club) {
    return GestureDetector(
      onTap: () => _openClubDetails(club),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  club.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                  ),
                  Text(
                    club.description,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color:
                              _getCategoryColor(club.category).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          club.category,
                          style: TextStyle(
                            fontSize: 9,
                            color: _getCategoryColor(club.category),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.people, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${club.memberCount} members',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _toggleJoin(club),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    club.isJoined ? Colors.green : Colors.deepPurple,
                minimumSize: const Size(70, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                club.isJoined ? 'Joined' : 'Join',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY & ERROR STATES
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
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
              onPressed: _loadClubs,
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
  // HELPERS
  // ═══════════════════════════════════════════════════════════
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

  void _openClubDetails(Club club) {
    Navigator.pushNamed(
      context,
      '/clubdetails',
      arguments: club.id,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return BottomNavigationBar(
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
          // Already here
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/myclubs');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
    );
  }
}