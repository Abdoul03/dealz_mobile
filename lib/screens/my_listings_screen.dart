import 'package:cached_network_image/cached_network_image.dart';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/screens/add_product_screen.dart';
import 'package:dealz/screens/product_detail_screen.dart';
import 'package:dealz/services/annonce_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final _service = AnnonceService();
  List<AnnonceModel> _annonces = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final annonces = await _service.getMesAnnonces();
      if (!mounted) return;
      setState(() => _annonces = annonces);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update(AnnonceModel annonce, String action) async {
    try {
      if (action == 'publish') {
        await _service.publierAnnonce(annonce.id);
      } else if (action == 'archive') {
        await _service.archiverAnnonce(annonce.id);
      } else {
        await _service.supprimerAnnonce(annonce.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_actionMessage(action))),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _actionMessage(String action) {
    switch (action) {
      case 'publish':
        return 'Annonce remise en ligne.';
      case 'archive':
        return 'Annonce archivée.';
      default:
        return 'Annonce supprimée.';
    }
  }

  Future<void> _confirmDelete(AnnonceModel annonce) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette annonce ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Garder'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _update(annonce, 'delete');
  }

  Future<void> _edit(AnnonceModel annonce) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(annonce: annonce),
      ),
    );
    if (updated == true && mounted) await _load();
  }

  List<AnnonceModel> _forStatus(String? status) => status == null
      ? _annonces
      : _annonces.where((annonce) => annonce.statut == status).toList();

  @override
  Widget build(BuildContext context) {
    const tabs = [
      Tab(text: 'Tout'),
      Tab(text: 'En ligne'),
      Tab(text: 'Réservées'),
      Tab(text: 'Vendues'),
      Tab(text: 'Archivées'),
    ];
    const statuses = [null, 'PUBLIEE', 'RESERVEE', 'VENDUE', 'ARCHIVEE'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Constant.backgroundColor,
        appBar: AppBar(
          title: const Text('Mes annonces'),
          actions: [
            IconButton(
              onPressed: _load,
              tooltip: 'Actualiser',
              icon: const Icon(LucideIcons.refresh_cw),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: tabs,
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : TabBarView(
                    children: statuses.map(_buildList).toList(),
                  ),
      ),
    );
  }

  Widget _buildList(String? status) {
    final annonces = _forStatus(status);
    if (annonces.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            Icon(LucideIcons.package_open, size: 54, color: Colors.black26),
            SizedBox(height: 14),
            Center(child: Text('Aucune annonce dans cette rubrique.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: annonces.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _listingCard(annonces[index]),
      ),
    );
  }

  Widget _listingCard(AnnonceModel annonce) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(annonce: annonce),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  height: 112,
                  child: annonce.urlImage == null
                      ? Container(
                          color: Constant.tertiaoreColor,
                          child: const Icon(LucideIcons.image),
                        )
                      : CachedNetworkImage(
                          imageUrl: annonce.urlImage!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: Constant.tertiaoreColor,
                            child: const Icon(LucideIcons.image_off),
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          annonce.titre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${annonce.prix.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            color: Constant.primaireColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _statusBadge(annonce.statut),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(LucideIcons.chevron_right, size: 18),
                ),
              ],
            ),
          ),
          if (annonce.statut == 'PUBLIEE' || annonce.statut == 'ARCHIVEE')
            const Divider(height: 1),
          if (annonce.statut == 'PUBLIEE' || annonce.statut == 'ARCHIVEE')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _edit(annonce),
                    icon: const Icon(LucideIcons.pencil, size: 16),
                    label: const Text('Modifier'),
                  ),
                  if (annonce.statut == 'PUBLIEE')
                    TextButton.icon(
                      onPressed: () => _update(annonce, 'archive'),
                      icon: const Icon(LucideIcons.archive, size: 16),
                      label: const Text('Archiver'),
                    ),
                  if (annonce.statut == 'ARCHIVEE') ...[
                    TextButton.icon(
                      onPressed: () => _confirmDelete(annonce),
                      icon: const Icon(LucideIcons.trash_2, size: 16),
                      label: const Text('Supprimer'),
                    ),
                    TextButton.icon(
                      onPressed: () => _update(annonce, 'publish'),
                      icon: const Icon(LucideIcons.send, size: 16),
                      label: const Text('Remettre en ligne'),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (label, color) = switch (status) {
      'PUBLIEE' => ('En ligne', Constant.primaireColor),
      'RESERVEE' => ('Réservée', Constant.secondaryColor),
      'VENDUE' => ('Vendue', Colors.black54),
      'ARCHIVEE' => ('Archivée', Colors.black45),
      _ => ('En préparation', Colors.black45),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Impossible de charger vos annonces.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
}
