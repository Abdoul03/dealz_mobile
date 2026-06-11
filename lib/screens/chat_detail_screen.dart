import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/message_model.dart';
import 'package:dealz/services/auth_service.dart';
import 'package:dealz/services/message_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ChatDetailScreen extends StatefulWidget {
  final String autreUserId;
  final String autreUserNom;
  final String annonceId;
  final String annonceTitre;

  const ChatDetailScreen({super.key, required this.autreUserId, required this.autreUserNom,
      required this.annonceId, required this.annonceTitre});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _service = MessageApiService();
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();
  List<MessageModel> _messages = [];
  String? _currentUserId;
  bool _loading = true, _sending = false;

  static const _quickReplies = ['Disponible ?', 'Négociable ?', 'Faire une offre', 'Où se voir ?'];

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() { _msgCtrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _init() async {
    _currentUserId = await AuthService().getCurrentUserId();
    await _loadMessages();
    _service.marquerConversationLue(widget.autreUserId, widget.annonceId);
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final msgs = await _service.getConversation(widget.autreUserId, widget.annonceId);
      setState(() => _messages = msgs);
      _scrollToBottom();
    } catch (_) {}
    finally { setState(() => _loading = false); }
  }

  Future<void> _send([String? quick]) async {
    final text = (quick ?? _msgCtrl.text).trim();
    if (text.isEmpty || _sending) { return; }
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      final msg = await _service.sendMessage(destinataireId: widget.autreUserId,
          annonceId: widget.annonceId, contenu: text);
      setState(() => _messages.add(msg));
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
    } finally { if (mounted) setState(() => _sending = false); }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) { _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.autreUserNom, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(widget.annonceTitre, style: TextStyle(color: Constant.primaireColor, fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [IconButton(icon: const Icon(LucideIcons.refresh_cw, color: Colors.black54, size: 18), onPressed: _loadMessages)],
      ),
      body: Column(children: [
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator())
            : _messages.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(LucideIcons.message_circle, size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Démarrez la conversation !', style: TextStyle(color: Colors.grey[500], fontSize: 15))]))
            : ListView.builder(controller: _scroll, padding: const EdgeInsets.all(16),
                itemCount: _messages.length, itemBuilder: (_, i) => _buildBubble(_messages[i]))),
        Container(height: 48, color: Colors.white,
            child: ListView.builder(scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                itemCount: _quickReplies.length,
                itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(backgroundColor: Colors.grey[100],
                        side: BorderSide(color: Colors.grey[300]!),
                        label: Text(_quickReplies[i], style: TextStyle(color: Constant.primaireColor, fontWeight: FontWeight.w600, fontSize: 13)),
                        onPressed: () => _send(_quickReplies[i]))))),
        Container(padding: const EdgeInsets.all(12), color: Colors.white,
            child: SafeArea(top: false, child: Row(children: [
              Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                  child: TextField(controller: _msgCtrl, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(hintText: 'Écrire un message...', border: InputBorder.none)))),
              const SizedBox(width: 8),
              GestureDetector(onTap: _send,
                  child: CircleAvatar(backgroundColor: Constant.primaireColor,
                      child: _sending ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(LucideIcons.send, color: Colors.white, size: 18))),
            ]))),
      ]),
    );
  }

  Widget _buildBubble(MessageModel msg) {
    final isMe = msg.expediteur.id == _currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? Constant.primaireColor : Colors.white,
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0), bottomRight: Radius.circular(isMe ? 0 : 16)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
        ),
        child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Text(msg.contenu, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
          const SizedBox(height: 3),
          Text('${msg.dateEnvoi.hour.toString().padLeft(2, '0')}:${msg.dateEnvoi.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: isMe ? Colors.white70 : Colors.grey[500], fontSize: 11)),
        ]),
      ),
    );
  }
}
