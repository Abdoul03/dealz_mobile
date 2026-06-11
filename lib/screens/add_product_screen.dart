import 'dart:convert';
import 'dart:io';
import 'package:dealz/_base/constant.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:dealz/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _pointRetraitCtrl = TextEditingController();

  final List<File> _images = [];
  static const int _maxImages = 5;

  String? _selectedCategorieId;
  String? _selectedEtat;
  List<Map<String, dynamic>> _categories = [];

  bool _isLoading = false;
  bool _loadingCategories = true;
  String? _errorMessage;

  static const List<Map<String, String>> _etats = [
    {'value': 'NEUF', 'label': 'Neuf'},
    {'value': 'TRES_BON_ETAT', 'label': 'Très bon état'},
    {'value': 'BON_ETAT', 'label': 'Bon état'},
    {'value': 'USAGE', 'label': 'Usagé'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    _pointRetraitCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final token = await AuthService().getAccessToken();
      final response = await http.get(
        Uri.parse('${Constant.remoteUrl}/categories'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _categories = data.map((e) => {'id': e['id'], 'nom': e['nom']}).toList().cast<Map<String, dynamic>>();
          _loadingCategories = false;
        });
      }
    } catch (_) {
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= _maxImages) {
      _showSnack('Maximum $_maxImages photos autorisées.');
      return;
    }
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _images.add(File(picked.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(LucideIcons.image),
            title: const Text('Galerie'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.camera),
            title: const Text('Appareil photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      _showSnack('Ajoutez au moins une photo.');
      return;
    }
    if (_selectedCategorieId == null) {
      _showSnack('Sélectionnez une catégorie.');
      return;
    }
    if (_selectedEtat == null) {
      _showSnack("Sélectionnez l'état de l'article.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Upload des images
      final imageUrls = await MediaService().uploadImages(_images);

      // 2. Création de l'annonce
      final token = await AuthService().getAccessToken();
      final body = jsonEncode({
        'titre': _titreCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'prix': double.parse(_prixCtrl.text.trim()),
        'urlImage': imageUrls.first,
        'urlImages': imageUrls,
        'etat': _selectedEtat,
        'categorieId': _selectedCategorieId,
        'pointRetrait': _pointRetraitCtrl.text.trim(),
      });

      final response = await http.post(
        Uri.parse('${Constant.remoteUrl}/annonces'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        _showSnack('Annonce créée avec succès !');
        Navigator.pop(context);
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() => _errorMessage = err['message'] ?? 'Erreur lors de la création.');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Constant.primaireColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constant.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Vendre un article',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PHOTOS ──────────────────────────────────────────────
              _sectionTitle('Photos (${_images.length}/$_maxImages)'),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Miniatures des images sélectionnées
                    ..._images.asMap().entries.map((entry) => _imageThumbnail(
                          entry.value,
                          entry.key,
                          isCover: entry.key == 0,
                        )),
                    // Bouton "Ajouter"
                    if (_images.length < _maxImages)
                      GestureDetector(
                        onTap: _showPickerSheet,
                        child: Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Constant.primaireColor, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.plus,
                                  color: Constant.primaireColor, size: 26),
                              const SizedBox(height: 4),
                              Text('Ajouter',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Constant.primaireColor)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── INFORMATIONS ─────────────────────────────────────────
              _sectionTitle('Informations'),
              const SizedBox(height: 12),
              _buildFormField(
                controller: _titreCtrl,
                label: "Titre de l'annonce",
                hint: 'Ex: Veste en jean Zara, taille L',
                validator: (v) =>
                    v!.trim().isEmpty ? 'Le titre est requis.' : null,
              ),
              _buildFormField(
                controller: _descCtrl,
                label: 'Description',
                hint: "Décrivez l'état, la taille, les défauts...",
                maxLines: 4,
                validator: (v) =>
                    v!.trim().isEmpty ? 'La description est requise.' : null,
              ),
              _buildFormField(
                controller: _prixCtrl,
                label: 'Prix (FCFA)',
                hint: 'Ex: 5000',
                keyboardType: TextInputType.number,
                icon: LucideIcons.circle_dollar_sign,
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Le prix est requis.';
                  if (double.tryParse(v.trim()) == null ||
                      double.parse(v.trim()) <= 0) {
                    return 'Entrez un prix valide.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ── CATÉGORIE ────────────────────────────────────────────
              _sectionTitle('Catégorie'),
              const SizedBox(height: 10),
              _loadingCategories
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ))
                  : _buildDropdown(
                      value: _selectedCategorieId,
                      hint: 'Sélectionnez une catégorie',
                      items: _categories
                          .map((c) => DropdownMenuItem<String>(
                              value: c['id'].toString(),
                              child: Text(c['nom'].toString())))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCategorieId = v),
                    ),

              const SizedBox(height: 16),

              // ── ÉTAT ─────────────────────────────────────────────────
              _sectionTitle("État de l'article"),
              const SizedBox(height: 10),
              _buildDropdown(
                value: _selectedEtat,
                hint: "Sélectionnez l'état",
                items: _etats
                    .map((e) => DropdownMenuItem<String>(
                        value: e['value'], child: Text(e['label']!)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedEtat = v),
              ),

              const SizedBox(height: 16),

              // ── LOCALISATION ─────────────────────────────────────────
              _sectionTitle('Point de retrait'),
              const SizedBox(height: 10),
              _buildFormField(
                controller: _pointRetraitCtrl,
                label: 'Adresse / Quartier',
                hint: 'Ex: Hamdallaye ACI 2000, Bamako',
                icon: LucideIcons.map_pin,
              ),

              const SizedBox(height: 20),

              // ── ERREUR ────────────────────────────────────────────────
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_errorMessage!,
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 13)),
                ),

              // ── BOUTON PUBLIER ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.primaireColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor:
                        Constant.primaireColor.withValues(alpha: 0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Text("Publier l'annonce",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageThumbnail(File file, int index, {bool isCover = false}) {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isCover
                ? Border.all(color: Constant.primaireColor, width: 2.5)
                : null,
            image: DecorationImage(
                image: FileImage(file), fit: BoxFit.cover),
          ),
        ),
        if (isCover)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Constant.primaireColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Cover',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        Positioned(
          top: 2,
          right: 10,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(LucideIcons.x,
                  size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87));
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              TextStyle(color: Colors.grey[600], fontSize: 13),
          hintStyle:
              TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: Constant.primaireColor)
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Constant.primaireColor, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          icon: Icon(LucideIcons.chevron_down,
              color: Constant.primaireColor, size: 18),
        ),
      ),
    );
  }
}
