import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/screens/product_card.dart';
import 'package:dealz/screens/product_detail_screen.dart';
import 'package:dealz/services/favori_service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoriService = FavoriService();
  List<AnnonceModel> _favoris = [];
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
      final favoris = await _favoriService.getMesFavoris();
      if (!mounted) return;
      setState(() => _favoris = favoris);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _retirer(AnnonceModel annonce) async {
    try {
      await _favoriService.retirer(annonce.id);
      if (!mounted) return;
      setState(() => _favoris.removeWhere((item) => item.id == annonce.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article retiré des favoris.')),
      );
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

  Future<void> _ouvrir(AnnonceModel annonce) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(annonce: annonce)),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text('Mes favoris'),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: Constant.primaireColor,
        child: _loading
            ? ListView(
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : _error != null
            ? _buildError()
            : _favoris.isEmpty
            ? _buildEmpty()
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        'Retrouvez ici les articles que vous souhaitez garder de côté.',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 0.78,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildCard(_favoris[index]),
                        childCount: _favoris.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard(AnnonceModel annonce) => GestureDetector(
    onTap: () => _ouvrir(annonce),
    child: ProductCard(
      titre: annonce.titre,
      marque: annonce.marque,
      taille: annonce.taille,
      etat: annonce.etatLabel,
      prix: annonce.prix,
      localisation: annonce.quartier,
      imageUrl: annonce.urlImage,
      isFavorite: true,
      onFavoriteChanged: (_) => _retirer(annonce),
    ),
  );

  Widget _buildError() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      const SizedBox(height: 180),
      Center(child: Text(_error ?? 'Impossible de charger vos favoris.')),
      const SizedBox(height: 12),
      Center(
        child: TextButton(onPressed: _load, child: const Text('Réessayer')),
      ),
    ],
  );

  Widget _buildEmpty() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: const [
      SizedBox(height: 180),
      Icon(Icons.favorite_border, size: 52, color: Colors.black26),
      SizedBox(height: 12),
      Center(child: Text('Vos articles favoris apparaîtront ici.')),
    ],
  );
}
