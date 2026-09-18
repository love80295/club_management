import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../services/club_service.dart';

class ClubDetailsScreen extends StatefulWidget {
  const ClubDetailsScreen({super.key});

  @override
  State<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int? _clubId;
  Club? _club;
  bool _isLoading = true;
  bool _isJoined = false;
  bool _isCoordinator = false;
  List<Map<String, dynamic>> _members = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _clubId == null) {
      _clubId = args;
      _loadClub();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD CLUB
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadClub() async {
    if (_clubId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ClubService.getClubDetail(_clubId!);

    if (!mounted) return;

    if (result['success'] == true) {
      final raw = result['raw'] as Map<String, dynamic>;
      final club = result['club'] as Club;
      final members = raw['members'] as List?;

      setState(() {
        _club = club;
        _isJoined = club.isJoined;
        _isCoordinator = raw['is_coordinator'] == true;
        _members =
            members != null ? List<Map<String, dynamic>>.from(members) : [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Failed to load club';
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // TOGGLE JOIN / LEAVE
  // ═══════════════════════════════════════════════════════════
  Future<void> _toggleJoin() async {
    if (_clubId == null) return;

    setState(() => _isLoading = true);

    final result = _isJoined
        ? await ClubService.leaveClub(_clubId!)
        : await ClubService.joinClub(_clubId!);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _isJoined = !_isJoined;
        _isLoading = false;
      });
      _showSnackBar(
        result['message'] ?? (_isJoined ? 'Joined!' : 'Left'),
        _isJoined ? Colors.green : Colors.orange,
      );
      _loadClub();
    } else {
      setState(() => _isLoading = false);
      _showSnackBar(result['message'] ?? 'Action failed', Colors.red);
    }
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
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading && _club == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Club Details'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    if (_errorMessage != null || _club == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Club Details'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 60, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Club not found',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadClub,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _club!.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _showSnackBar('Share coming soon!', Colors.deepPurple);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClub,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildClubHeader(),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CLUB HEADER
  // ═══════════════════════════════════════════════════════════
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
              // Logo
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
                child: _club!.logo != null && _club!.logo!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _club!.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              _club!.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _club!.name[0].toUpperCase(),
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
                      _club!.name,
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
                        _club!.category,
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
                          '${_club!.memberCount} members',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        if (_isCoordinator) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // JOIN / LEAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCoordinator ? null : _toggleJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCoordinator
                    ? Colors.grey.shade300
                    : (_isJoined ? Colors.white : Colors.deepPurple),
                foregroundColor: _isJoined ? Colors.deepPurple : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isCoordinator)
                    const Icon(Icons.star, size: 18)
                  else
                    Icon(_isJoined ? Icons.check_circle : Icons.add_circle),
                  const SizedBox(width: 8),
                  Text(
                    _isCoordinator
                        ? 'You are the Coordinator'
                        : (_isJoined ? 'Joined' : 'Join Club'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // MANAGE CLUB BUTTON (Only for Coordinator)
          if (_isCoordinator) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/adminpanel',
                    arguments: _clubId,
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text(
                  'Manage Club',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ABOUT TAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _club!.description.isNotEmpty
                ? _club!.description
                : 'No description available.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          // INFO CARD
          // ═══════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.category, 'Category', _club!.category),
                const Divider(height: 20),
                _buildInfoRow(
                  Icons.people,
                  'Members',
                  '${_club!.memberCount} members',
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Created',
                  _club!.createdAt.isNotEmpty
                      ? _club!.createdAt.split('T').first
                      : 'Recently',
                ),
                // Instagram (only if exists)
                if (_club!.instagramHandle.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.photo_camera,
                    'Instagram',
                    _club!.instagramHandle,
                  ),
                ],
                // Email (only if exists)
                if (_club!.clubEmail.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    _club!.clubEmail,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          // CONNECT WITH US
          // ═══════════════════════════════════════════════════
          const Text(
            'Connect with us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Instagram
              if (_club!.instagramHandle.isNotEmpty)
                _buildSocialChip(
                  Icons.photo_camera,
                  _club!.instagramHandle,
                  Colors.pink,
                ),
              // Email
              if (_club!.clubEmail.isNotEmpty)
                _buildSocialChip(
                  Icons.email,
                  _club!.clubEmail,
                  Colors.blue,
                ),
            ],
          ),
          // If no contact info
          if (_club!.instagramHandle.isEmpty && _club!.clubEmail.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No contact information available',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ACTIVITIES TAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildActivitiesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'No activities yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Events from this club will appear here',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/explore');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Events'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MEMBERS TAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildMembersTab() {
    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'No members yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        final isCoordinator = member['is_coordinator'] == true;
        final name = member['name'] ?? member['username'] ?? 'Unknown';
        final email = member['email'] ?? '';
        final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isCoordinator
                ? Border.all(color: Colors.amber.shade300, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCoordinator
                      ? Colors.amber.shade100
                      : Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCoordinator
                          ? Colors.amber.shade800
                          : Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCoordinator)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
          Navigator.pushReplacementNamed(context, '/explore');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/myclubs');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
    );
  }
}