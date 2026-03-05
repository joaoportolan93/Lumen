import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dreamshare/models/user.dart';
import 'package:dreamshare/models/dream.dart';
import 'package:dreamshare/services/user_service.dart';
import 'package:dreamshare/services/dream_service.dart';
import 'package:dreamshare/views/widgets/dream_card.dart';

class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final UserService _userService = UserService();
  final DreamService _dreamService = DreamService();
  User? _user;
  List<Dream> _dreams = [];
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getUserDetail(widget.userId);
      final dreams = await _dreamService.getUserDreams(widget.userId);
      setState(() {
        _user = user;
        _dreams = dreams;
        _isFollowing = user?.isFollowing ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    bool success;
    setState(() => _isFollowing = !_isFollowing);

    if (_isFollowing) {
      success = await _userService.followUser(widget.userId);
    } else {
      success = await _userService.unfollowUser(widget.userId);
    }

    if (!success) {
      setState(() => _isFollowing = !_isFollowing);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha na operação. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Usuário não encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('@${_user!.nomeUsuario}'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundImage: _user!.avatar != null
                    ? CachedNetworkImageProvider(_user!.avatar!)
                    : null,
                child: _user!.avatar == null
                    ? Text(
                        _user!.nomeUsuario.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // Full name
              Text(
                _user!.nomeCompleto,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Bio
              if (_user!.bio != null && _user!.bio!.isNotEmpty)
                Text(
                  _user!.bio!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),

              const SizedBox(height: 16),

              // Follow button
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.secondary,
                    foregroundColor: _isFollowing ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    _isFollowing ? 'Seguindo' : 'Seguir',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('Sonhos', _user!.sonhosCount),
                  _buildStat('Seguidores', _user!.seguidoresCount),
                  _buildStat('Seguindo', _user!.seguindoCount),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // User dreams
              if (_dreams.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Nenhum sonho publicado ainda',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              else
                ..._dreams.map(
                    (dream) => DreamCard(dream: dream, onUpdate: _loadProfile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
