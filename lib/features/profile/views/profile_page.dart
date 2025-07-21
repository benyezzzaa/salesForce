import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/features/profile/controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header avec photo de profil
                _buildProfileHeader(context, colorScheme),
                const SizedBox(height: 24),
                
                // Informations personnelles
                _buildPersonalInfo(context, colorScheme),
                const SizedBox(height: 24),
                
                // Actions du profil
                _buildProfileActions(context, colorScheme),
                const SizedBox(height: 24),
                
                // Bouton de déconnexion
                _buildLogoutButton(context, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Photo de profil
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 50,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Nom et prénom
            Obx(() => Text(
              '${widget.controller.prenom.value} ${widget.controller.nom.value}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 8),
            
            // Rôle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Commercial',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 Informations Personnelles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Nom', widget.controller.nom.value, Icons.person, colorScheme),
            const SizedBox(height: 12),
            _buildInfoRow('Prénom', widget.controller.prenom.value, Icons.person_outline, colorScheme),
            const SizedBox(height: 12),
            _buildInfoRow('Email', widget.controller.email.value, Icons.email, colorScheme),
            const SizedBox(height: 12),
            _buildInfoRow('Téléphone', widget.controller.tel.value, Icons.phone, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileActions(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: colorScheme.primary),
            title: const Text('Modifier le profil'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Action pour modifier le profil
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.notifications, color: colorScheme.primary),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Get.toNamed(AppRoutes.notificationsPage),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.settings, color: colorScheme.primary),
            title: const Text('Paramètres'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Action pour les paramètres
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    print('🚪 MANUAL LOGOUT - User clicked logout button');
    print('🧹 Clearing session data...');
    
    final storage = GetStorage();
    storage.remove('token');
    storage.remove('user_id');
    storage.remove('user');
    storage.remove('login_timestamp');
    
    // Forcer la synchronisation
    storage.save();
    
    print('✅ Session cleared successfully');
    print('🔄 Redirecting to login page...');
    
    Get.offAllNamed(AppRoutes.loginPage);
  }
}
