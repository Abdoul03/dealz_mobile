import 'dart:convert';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/screens/login_screen.dart';
import 'package:dealz/services/annonce_service.dart';
import 'package:dealz/services/api_client.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:dealz/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Map<String, dynamic>? _user;
  int _nbAnnonces = 0;
  int _nbAchats = 0;
  int _nbVentes = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiClient.get('/user/me'),
        AnnonceService().getMesAnnonces(),
        TransactionService().getMesAchats(),
        TransactionService().getMesVentes(),
      ]);

      final userResp = results[0] as dynamic;
      if ((userResp).statusCode == 200) {
        setState(() {
          _user = jsonDecode((userResp).body) as Map<String, dynamic>;
        });
      }

      setState(() {
        _nbAnnonces = (results[1] as List).length;
        _nbAchats = (results[2] as List).length;
        _nbVentes = (results[3] as List).length;
      });
    } catch (_) {
      // On affiche quand même ce qu'on a
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nom = _user != null
        ? '${_user!['prenom'] ?? ''} ${_user!['nom'] ?? ''}'.trim()
        : 'Chargement...';
    final localisation = _user?['localisation'] as String? ?? '';
    final noteMoyenne = (_user?['noteMoyenne'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text('Mon Profil',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Constant.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Constant.primaireColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                child: Icon(LucideIcons.user,
                                    size: 50, color: Colors.grey[400]),
                              ),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Constant.primaireColor,
                                child: const Icon(LucideIcons.camera,
                                    size: 16, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(nom,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          if (localisation.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.map_pin,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(localisation,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (noteMoyenne > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    i < noteMoyenne.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFFFB100),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  noteMoyenne.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.black54),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Statistiques
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('$_nbAnnonces', 'Annonces'),
                          _buildStatDivider(),
                          _buildStatItem('$_nbAchats', 'Achats'),
                          _buildStatDivider(),
                          _buildStatItem('$_nbVentes', 'Ventes'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Menu
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildMenuTile(
                              icon: LucideIcons.package,
                              title: 'Mes objets en vente',
                              subtitle: 'Gérer ou modifier vos annonces',
                              onTap: () {}),
                          _buildDivider(),
                          _buildMenuTile(
                              icon: LucideIcons.history,
                              title: 'Historique des transactions',
                              subtitle: 'Achats et ventes terminés',
                              onTap: () {}),
                          _buildDivider(),
                          _buildMenuTile(
                              icon: LucideIcons.heart,
                              title: 'Mes favoris',
                              subtitle: 'Articles sauvegardés',
                              onTap: () {}),
                          _buildDivider(),
                          _buildMenuTile(
                              icon: LucideIcons.store,
                              title: 'Devenir Commerçant Pro',
                              subtitle: 'Boutique dédiée à 5 000 FCFA / mois',
                              iconColor: Constant.secondaryColor,
                              onTap: () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextButton.icon(
                      onPressed: () async {
                        await AuthService().logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (_) => false,
                        );
                      },
                      icon: const Icon(LucideIcons.log_out,
                          color: Colors.redAccent, size: 18),
                      label: const Text('Se déconnecter',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constant.primaireColor)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatDivider() =>
      Container(height: 30, width: 1, color: Colors.grey[200]);

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              (iconColor ?? Constant.primaireColor).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: iconColor ?? Constant.primaireColor, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: const Icon(LucideIcons.chevron_right,
          size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => Padding(
        padding: const EdgeInsets.only(left: 70),
        child: Divider(height: 1, color: Colors.grey[100]),
      );
}
