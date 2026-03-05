import 'package:flutter/material.dart';
import 'package:dreamshare/models/community.dart';
import 'package:dreamshare/models/dream.dart';
import 'package:dreamshare/services/community_service.dart';
import 'package:dreamshare/views/widgets/dream_card.dart';

class CommunityDetail extends StatefulWidget {
  final String communityId;

  const CommunityDetail({super.key, required this.communityId});

  @override
  _CommunityDetailState createState() => _CommunityDetailState();
}

class _CommunityDetailState extends State<CommunityDetail> {
  final CommunityService _communityService = CommunityService();
  Community? _community;
  List<Dream> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _communityService.getCommunityDetail(widget.communityId),
      _communityService.getCommunityPosts(widget.communityId),
    ]);
    setState(() {
      _community = results[0] as Community?;
      _posts = results[1] as List<Dream>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_community?.nome ?? 'Comunidade'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Community header
                  if (_community != null) ...[
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        child: Text(
                          _community!.nome.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _community!.nome,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_community!.descricao != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _community!.descricao!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '${_community!.membrosCount} membros',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_community!.isMembro)
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _communityService.joinCommunity(widget.communityId);
                            _loadData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Entrar na Comunidade'),
                        ),
                      ),
                    const Divider(height: 32),
                  ],

                  // Posts
                  if (_posts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nenhum sonho nesta comunidade',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._posts.map((dream) => DreamCard(dream: dream, onUpdate: _loadData)),
                ],
              ),
            ),
    );
  }
}
