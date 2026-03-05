import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dreamshare/models/dream.dart';
import 'package:dreamshare/models/comment.dart';
import 'package:dreamshare/services/dream_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class DreamDetail extends StatefulWidget {
  final String dreamId;

  const DreamDetail({super.key, required this.dreamId});

  @override
  _DreamDetailState createState() => _DreamDetailState();
}

class _DreamDetailState extends State<DreamDetail> {
  final DreamService _dreamService = DreamService();
  final TextEditingController _commentController = TextEditingController();
  Dream? _dream;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _dreamService.getDreamDetail(widget.dreamId),
      _dreamService.getComments(widget.dreamId),
    ]);
    setState(() {
      _dream = results[0] as Dream?;
      _comments = results[1] as List<Comment>;
      _isLoading = false;
    });
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPostingComment = true);
    final comment = await _dreamService.createComment(widget.dreamId, text);
    setState(() => _isPostingComment = false);

    if (comment != null) {
      _commentController.clear();
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sonho')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dream == null
              ? const Center(child: Text('Sonho não encontrado'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Dream header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: _dream!.usuario?.avatar != null
                                    ? CachedNetworkImageProvider(_dream!.usuario!.avatar!)
                                    : null,
                                child: _dream!.usuario?.avatar == null
                                    ? Text(_dream!.usuario?.nomeUsuario.substring(0, 1).toUpperCase() ?? '?')
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dream!.usuario?.nomeUsuario ?? 'Anônimo',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    timeago.format(_dream!.dataPublicacao, locale: 'pt_BR'),
                                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dream content
                          Text(
                            _dream!.conteudoTexto,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),

                          // Hashtags
                          if (_dream!.hashtags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: _dream!.hashtags.map((tag) {
                                return Text(
                                  tag.startsWith('#') ? tag : '#$tag',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Image
                          if (_dream!.imagem != null) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: _dream!.imagem!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],

                          // Stats
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.red, size: 18),
                              const SizedBox(width: 4),
                              Text('${_dream!.curtidasCount}'),
                              const SizedBox(width: 16),
                              Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                              const SizedBox(width: 4),
                              Text('${_comments.length}'),
                            ],
                          ),

                          const Divider(height: 32),

                          // Comments section
                          const Text(
                            'Comentários',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          if (_comments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'Nenhum comentário ainda. Seja o primeiro!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ..._comments.map((comment) => _buildCommentTile(comment)),
                        ],
                      ),
                    ),

                    // Comment input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: 'Escreva um comentário...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _isPostingComment
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : IconButton(
                                    onPressed: _postComment,
                                    icon: Icon(
                                      Icons.send_rounded,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.usuario?.avatar != null
                ? CachedNetworkImageProvider(comment.usuario!.avatar!)
                : null,
            child: comment.usuario?.avatar == null
                ? Text(comment.usuario?.nomeUsuario.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 12))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${comment.usuario?.nomeUsuario ?? 'Anônimo'} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.conteudoTexto),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(comment.dataCriacao, locale: 'pt_BR'),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
