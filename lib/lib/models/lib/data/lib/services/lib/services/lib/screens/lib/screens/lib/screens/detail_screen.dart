import 'package:flutter/material.dart';
import '../models/desenho.dart';
import '../services/print_service.dart';
import '../services/favorites_service.dart';

class DetailScreen extends StatefulWidget {
  final Desenho desenho;
  const DetailScreen({super.key, required this.desenho});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _imprimindo = false;
  bool _favorito = false;

  @override
  void initState() {
    super.initState();
    _carregarFavorito();
  }

  Future<void> _carregarFavorito() async {
    final ehFav = await FavoritesService.ehFavorito(widget.desenho.id);
    if (mounted) setState(() => _favorito = ehFav);
  }

  Future<void> _alternarFavorito() async {
    await FavoritesService.alternarFavorito(widget.desenho.id);
    await _carregarFavorito();
  }

  Future<void> _imprimir() async {
    setState(() => _imprimindo = true);
    try {
      await PrintService.imprimirDesenho(
        caminhoAsset: widget.desenho.caminhoArquivo,
        nomeDocumento: widget.desenho.titulo,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao imprimir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _imprimindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.desenho.titulo),
        actions: [
          IconButton(
            icon: Icon(_favorito ? Icons.favorite : Icons.favorite_border),
            color: _favorito ? Colors.red : null,
            onPressed: _alternarFavorito,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.desenho.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 80),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: _imprimindo
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print),
                label: Text(_imprimindo ? 'Abrindo impressão...' : 'Imprimir'),
                onPressed: _imprimindo ? null : _imprimir,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
