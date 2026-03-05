import 'package:flutter/material.dart';
import 'package:dreamshare/models/dream.dart';
import 'package:dreamshare/services/dream_service.dart';
import 'package:dreamshare/views/widgets/dream_card.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DreamService _dreamService = DreamService();
  List<Dream> _dreams = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final dreams = await _dreamService.getFeed();
      setState(() {
        _dreams = dreams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dream Share',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDreams,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar sonhos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadDreams,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_dreams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nightlight_round, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum sonho ainda...',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Seja o primeiro a compartilhar!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDreams,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _dreams.length,
        itemBuilder: (context, index) {
          return DreamCard(dream: _dreams[index], onUpdate: _loadDreams);
        },
      ),
    );
  }
}
