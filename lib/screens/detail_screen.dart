import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import '../models/desenho.dart';
import '../services/print_service.dart';
import '../services/favorites_service.dart';
import '../services/print_history_service.dart';
import '../widgets/paper_size_dialog.dart';

class DetailScreen extends StatefulWidget {
  final Desenho desenho;
  const DetailScreen({super.key, required this.desenho});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _imprimindo = false;
  bool _favorito = false;
  bool _jaImpresso = false;

  @override
  void initState() {
    super.initState();
    _carregarFavorito();
    _carregarHistorico();
  }

  Future<void> _carregarFavorito() async {
    final ehFav = await FavoritesService.ehFavorito(widget.desenho.id);
    if (mounted) setState(() => _favorito = ehFav);
  }

  Future<void> _carregarHistorico() async {
    final impresso = await PrintHistoryService.foiImpresso(widget.desenho.id);
    if (mounted) setState(() => _jaImpresso = impresso);
  }

  Future<void> _alternarFavorito() async {
    await FavoritesService.alternarFavorito(widget.desenho.id);
    await _carregarFavorito();
  }

  Future<void> _talvezPedirAvaliacao() async {
    final impressos = await PrintHistoryService.obterImpressos();
    if (impressos.length == 3 || impressos.length == 10) {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    }
  }

  Future<void> _imprimir() async {
    final formato = await escolherTamanhoPapel(context);
    if (formato == null) return;

    setState(() => _imprimindo = true);
    try {
      await PrintService.imprimirDesenho(
        caminhoAsset: widget.desenho.caminhoArquivo,
        nomeDocumento: widget.desenho.titulo,
        formato: formato,
      );
      await PrintHistoryService.marcarComoImpresso(widget.desenho.id);
      await _carregarHistorico();
      await _talvezPedirAvaliacao();
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
          if (_jaImpresso)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.check_circle, color: Colors.green),
            ),
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
          if (_jaImpresso)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Você já imprimiu este desenho',
                style: TextStyle(color: Colors.grey),
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
