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
  final _sizeFilterCtrl = TextEditingController();
  final _minimumPriceCtrl = TextEditingController();
  final _maximumPriceCtrl = TextEditingController();
  final _scrollController = ScrollController();

  List<CategorieModel> _categories = [];
  List<AnnonceModel> _annonces = [];
  String? _selectedCategorieId;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  int _requestSequence = 0;
  String? _error;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    _sizeFilterCtrl.dispose();
    _minimumPriceCtrl.dispose();
    _maximumPriceCtrl.dispose();
    _scrollController.dispose();
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
    final sequence = ++_requestSequence;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _hasMore = true;
      _page = 0;
      _error = null;
    });
    try {
      final annonces = await _annonceService.getAnnonces(
        categorieId: _selectedCategorieId,
        motCle: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        taille: _sizeFilterCtrl.text.trim().isEmpty
            ? null
            : _sizeFilterCtrl.text.trim(),
        prixMin: double.tryParse(_minimumPriceCtrl.text.trim()),
        prixMax: double.tryParse(_maximumPriceCtrl.text.trim()),
      );
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _annonces = annonces;
        _hasMore = annonces.length == 20;
      });
    } catch (e) {
      if (!mounted || sequence != _requestSequence) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted && sequence == _requestSequence) {
        setState(() => _loading = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final sequence = _requestSequence;
    final nextPage = _page + 1;
    setState(() => _loadingMore = true);
    try {
      final annonces = await _annonceService.getAnnonces(
        categorieId: _selectedCategorieId,
        motCle: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        taille: _sizeFilterCtrl.text.trim().isEmpty
            ? null
            : _sizeFilterCtrl.text.trim(),
        prixMin: double.tryParse(_minimumPriceCtrl.text.trim()),
        prixMax: double.tryParse(_maximumPriceCtrl.text.trim()),
        page: nextPage,
      );
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _annonces = [..._annonces, ...annonces];
        _page = nextPage;
        _hasMore = annonces.length == 20;
      });
    } catch (_) {
      // La première page reste consultable si le réseau coupe pendant le chargement.
    } finally {
      if (mounted && sequence == _requestSequence) {
        setState(() => _loadingMore = false);
      }
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

  Future<void> _showFilters() async {
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Affiner la recherche',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _sizeFilterCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Taille',
                hintText: 'Ex. M, 38 ou taille unique',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minimumPriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prix minimum',
                      suffixText: 'FCFA',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maximumPriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prix maximum',
                      suffixText: 'FCFA',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _sizeFilterCtrl.clear();
                    _minimumPriceCtrl.clear();
                    _maximumPriceCtrl.clear();
                    Navigator.pop(context, true);
                  },
                  child: const Text('Effacer'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Voir les articles'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (applied == true) await _loadAnnonces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constant.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ProfilScreen())),
            child: const CircleAvatar(
              backgroundColor: Constant.tertiaoreColor,
              child: Icon(LucideIcons.user, color: Constant.primaireColor, size: 20),
            ),
          ),
        ),
        title: Text(
          'dealz',
          style: TextStyle(
            color: Constant.primaireColor,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
            fontSize: 23,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.message_circle, color: Constant.primaireColor),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => MessageScreen())),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(LucideIcons.shopping_bag, color: Constant.primaireColor),
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
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.map_pin, size: 14, color: Constant.primaireColor),
                        const SizedBox(width: 5),
                        Text(
                          'BAMAKO, MALI',
                          style: TextStyle(
                            color: Constant.primaireColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'La mode continue\nsa vie ici.',
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'De belles pièces de seconde main à découvrir dans la ville.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // Barre de recherche
            SliverAppBar(
              expandedHeight: 55,
              floating: true,
              pinned: true,
              backgroundColor: Constant.backgroundColor,
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
                    ActionChip(
                      avatar: Icon(
                        LucideIcons.sliders_horizontal,
                        size: 15,
                        color: Constant.primaireColor,
                      ),
                      label: Text(
                        _sizeFilterCtrl.text.isNotEmpty ||
                                _minimumPriceCtrl.text.isNotEmpty ||
                                _maximumPriceCtrl.text.isNotEmpty
                            ? 'Filtres actifs'
                            : 'Filtres',
                      ),
                      onPressed: _showFilters,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'À dénicher',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (!_loading && _annonces.isNotEmpty)
                      Text(
                        '${_annonces.length}${_hasMore ? '+' : ''} articles',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
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
                          marque: a.marque,
                          taille: a.taille,
                          etat: a.etatLabel,
                          prix: a.prix,
                          localisation: a.quartier,
                          imageUrl: a.urlImage,
                        ),
                      );
                    },
                    childCount: _annonces.length,
                  ),
                ),
              ),
            if (_loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
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
