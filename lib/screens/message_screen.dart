import 'package:dealz/_base/constant.dart';
import 'package:dealz/models/conversation_resume_model.dart';
import 'package:dealz/screens/chat_detail_screen.dart';
import 'package:dealz/services/message_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});
  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _service = MessageApiService();
  List<ConversationResumeModel> _conversations = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { final c = await _service.getConversationsResume(); setState(() => _conversations = c); } catch (_) {}
    finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.backgroundColor,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [IconButton(icon: const Icon(LucideIcons.refresh_cw, color: Colors.black54, size: 20), onPressed: _load)],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load, color: Constant.primaireColor,
              child: _conversations.isEmpty ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _conversations.length,
                      itemBuilder: (_, i) => _buildTile(_conversations[i]),
                    ),
            ),
    );
  }

  Widget _buildTile(ConversationResumeModel conv) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
            autreUserId: conv.interlocuteur.id, autreUserNom: conv.interlocuteur.nomComplet,
            annonceId: conv.annonceId, annonceTitre: conv.annonceTitre)));
          _load();
        },
        leading: CircleAvatar(radius: 26, backgroundColor: Constant.primaireColor.withValues(alpha: 0.1),
            child: Icon(LucideIcons.user, color: Constant.primaireColor, size: 22)),
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(conv.interlocuteur.nomComplet,
              style: TextStyle(fontWeight: conv.hasUnread ? FontWeight.bold : FontWeight.w600, fontSize: 15),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(_fmt(conv.dateEnvoi), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
        subtitle: Padding(padding: const EdgeInsets.only(top: 3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(conv.annonceTitre, style: TextStyle(color: Constant.primaireColor, fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(conv.dernierMessage, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: conv.hasUnread ? Colors.black87 : Colors.grey[600], fontSize: 13,
                  fontWeight: conv.hasUnread ? FontWeight.w500 : FontWeight.normal)),
        ])),
        trailing: conv.hasUnread
            ? Container(width: 10, height: 10, decoration: BoxDecoration(color: Constant.primaireColor, shape: BoxShape.circle))
            : const Icon(LucideIcons.chevron_right, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmpty() => ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.6,
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.message_square, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Aucune discussion pour le moment.', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
      ])))]);

  String _fmt(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Maintenant';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${d.day}/${d.month}';
  }
}
