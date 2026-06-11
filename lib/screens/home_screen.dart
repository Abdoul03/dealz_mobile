import 'dart:async';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/main.dart';
import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/models/categorie_model.dart';
import 'package:dealz/screens/add_product_screen.dart';
import 'package:dealz/screens/cart_screen.dart';
import 'package:dealz/screens/message_screen.dart';
import 'package:dealz/screens/product_card.dart';
import 'package:dealz/screens/product_detail_screen.dart';
import 'package:dealz/screens/profil_screen.dart';
import 'package:dealz/services/annonce_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final _annonceService = AnnonceService();
  final _searchCtrl = TextEditingController();

  List<CategorieModel> _categories = [];
  List<AnnonceModel> _annonces = [];
  String? _selectedCategorieId;
  bool _loading = true;
  String? _error;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchCtrl.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  // Appelé quand on revient sur HomeScreen depuis une autre page
  @override
  void didPopNext() {
    _loadAnnonces();
  }

  Future<void> _init() async {
    try {
      final cats = await _annonceService.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {
      // Catégories non disponibles, on continue sans elles
    }
    await _loadAnnonces();
  }

  Future<void> _loadAnnonces() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final annonces = await _annonceService.getAnnonces(
        categorieId: _selectedCategorieId,
        motCle: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      setState(() => _annonces = annonces);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), _loadAnnonces);
  }

  void _selectCategorie(String? categorieId) {
    setState(() => _selectedCategorieId = categorieId);
    _loadAnnonces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constant.primaireColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ProfilScreen())),
            child: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(LucideIcons.user, color: Colors.white, size: 20),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.message_circle, color: Colors.white),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => MessageScreen())),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.shopping_cart, color: Colors.white),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => CartScreen())),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: Constant.primaireColor,
        onRefresh: _loadAnnonces,
        child: CustomScrollView(
          slivers: [
            // Barre de recherche
            SliverAppBar(
              expandedHeight: 55,
              floating: true,
              pinned: true,
              backgroundColor: Constant.primaireColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                centerTitle: true,
                title: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle:
                          const TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: Icon(LucideIcons.search,
                          size: 20, color: Constant.primaireColor),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x,
                                  size: 16, color: Colors.grey),
                              onPressed: () {
                                _searchCtrl.clear();
                                _loadAnnonces();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ),

            // Chips catégories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  children: [
                    _categoryChip(null, 'Tout'),
                    ..._categories.map((c) => _categoryChip(c.id, c.nom)),
                  ],
                ),
              ),
            ),

            // Contenu principal
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(child: _buildError())
            else if (_annonces.isEmpty)
              SliverFillRemaining(child: _buildEmpty())
            else
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final a = _annonces[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(annonce: a),
                          ),
                        ),
                        child: ProductCard(
                          titre: a.titre,
                          prix: a.prix,
                          localisation: a.pointRetrait,
                          imageUrl: a.urlImage,
                        ),
                      );
                    },
                    childCount: _annonces.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (created == true && mounted) _loadAnnonces();
        },
        backgroundColor: Constant.primaireColor,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Vendre',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _categoryChip(String? id, String label) {
    final selected = _selectedCategorieId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: Constant.primaireColor,
        backgroundColor: Colors.white,
        elevation: 0,
        pressElevation: 0,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => _selectCategorie(id),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.wifi_off, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAnnonces,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Constant.primaireColor),
              child: const Text('Réessayer',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.package, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Aucune annonce trouvée.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }
}
