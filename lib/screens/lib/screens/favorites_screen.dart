import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/desenho.dart';
import '../services/favorites_service.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Desenho> _favoritos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final ids = await FavoritesService.obterFavoritos();
    setState(() {
      _favoritos = desenhosExemplo.where((d) => ids.contains(d.id)).toList();
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _favoritos.isEmpty
              ? const Center(child: Text('Você ainda não tem favoritos.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _favoritos.length,
                  itemBuilder: (context, index) {
                    final desenho = _favoritos[index];
                    return _FavoritoThumbnail(
                      desenho: desenho,
                      onVoltar: _carregarFavoritos,
                    );
                  },
                ),
    );
  }
}

class _FavoritoThumbnail extends StatelessWidget {
  final Desenho desenho;
  final VoidCallback onVoltar;
  const _FavoritoThumbnail({required this.desenho, required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(desenho: desenho)),
        );
        onVoltar();
      },
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                desenho.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(desenho.titulo, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
