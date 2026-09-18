import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/club_service.dart';
import '../services/image_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _user;
  int _clubsCount = 0;
  int _eventsCount = 0;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD PROFILE
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get cached user first
    final cached = await AuthService.getCachedUser();
    if (cached != null && mounted) {
      setState(() => _user = cached);
    }

    // Fetch fresh data
    final results = await Future.wait([
      AuthService.getProfile(),
      ClubService.getMyClubs(),
    ]);

    if (!mounted) return;

    final profileResult = results[0] as Map<String, dynamic>;
    final clubsResult = results[1] as Map<String, dynamic>;

    setState(() {
      if (profileResult['success'] == true) {
        _user = profileResult['user'];
      }
      if (clubsResult['success'] == true) {
        _clubsCount = (clubsResult['clubs'] as List).length;
      }
      _isLoading = false;

      if (profileResult['statusCode'] == 401) {
        _handleSessionExpired();
      }
    });
  }

  void _handleSessionExpired() {
    AuthService.logout().then((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE PROFILE PICTURE
  // ═══════════════════════════════════════════════════════════
  Future<void> _changeProfilePicture() async {
    final file = await ImageService.showPicker(context);
    if (file == null) return;

    setState(() => _isUploading = true);

    final result = await AuthService.updateProfile(
      profilePicPath: file.path,
    );

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (result['success'] == true) {
      setState(() => _user = result['user']);
      _showSnackBar('Profile picture updated!', Colors.green);
    } else {
      _showSnackBar(result['message'] ?? 'Failed to update', Colors.red);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════
  void _showAchievements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Achievements'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _achievementItem('Club Member', 'Joined first club', _clubsCount >= 1),
            const SizedBox(height: 8),
            _achievementItem('Active Participant', 'Join 5 clubs', _clubsCount >= 5),
            const SizedBox(height: 8),
            _achievementItem('Event Enthusiast', 'Register for event', _eventsCount >= 1),
            const SizedBox(height: 8),
            _achievementItem('Campus Star', 'Join all clubs', _clubsCount >= 5),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _achievementItem(String title, String subtitle, bool unlocked) {
    return Row(
      children: [
        Icon(
          unlocked ? Icons.check_circle : Icons.lock,
          color: unlocked ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: unlocked ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Refresh',
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
                    onRefresh: _loadProfile,
                    color: Colors.deepPurple,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 16),
                          _buildStatsSection(),
                          const SizedBox(height: 16),
                          _buildMenuSection(),
                          const SizedBox(height: 16),
                          _buildLogoutButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PROFILE HEADER (With Editable Picture)
  // ═══════════════════════════════════════════════════════════
  Widget _buildProfileHeader() {
    final hasImage = _user?.profilePic != null && _user!.profilePic!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // ═══════════════════════════════════════════════════
          // PROFILE PICTURE (Tap to change)
          // ═══════════════════════════════════════════════════
          GestureDetector(
            onTap: _isUploading ? null : _changeProfilePicture,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _isUploading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                              strokeWidth: 3,
                            ),
                          )
                        : hasImage
                            ? Image.network(
                                _user!.profilePic!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (_, __, ___) => _buildInitials(),
                              )
                            : _buildInitials(),
                  ),
                ),
                // Camera icon overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            _user?.fullName ?? _user?.username ?? 'Student',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          if (_user?.department.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              '${_user!.department} | ${_user!.year}',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _user?.role.toUpperCase() ?? 'STUDENT',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap profile picture to change',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          _user?.initials ?? '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATS
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            _clubsCount.toString(),
            'Clubs Joined',
            Icons.group,
            Colors.deepPurple,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildStatItem(
            _eventsCount.toString(),
            'Events',
            Icons.event,
            Colors.blue,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildStatItem(
            '0',
            'Certificates',
            Icons.emoji_events,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MENU
  // ═══════════════════════════════════════════════════════════
  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.group,
            title: 'My Clubs',
            subtitle: 'View all joined clubs',
            onTap: () => Navigator.pushReplacementNamed(context, '/myclubs'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.event,
            title: 'My Events',
            subtitle: 'View your event registrations',
            onTap: () => Navigator.pushReplacementNamed(context, '/explore'),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.emoji_events,
            title: 'Achievements',
            subtitle: 'View your earned badges',
            onTap: _showAchievements,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App settings and preferences',
            onTap: () => _showSnackBar('Settings coming soon!', Colors.orange),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'FAQs and contact support',
            onTap: () => _showSnackBar('Help coming soon!', Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepPurple, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100);
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ERROR
  // ═══════════════════════════════════════════════════════════
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
              onPressed: _loadProfile,
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
      currentIndex: 3,
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
          // Already here
        }
      },
    );
  }
}