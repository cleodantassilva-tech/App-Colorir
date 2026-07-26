import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/desenho.dart';
import '../services/asset_scanner.dart';
import '../services/featured_service.dart';
import '../services/purchase_service.dart';
import 'favorites_screen.dart';
import 'gallery_screen.dart';
import 'detail_screen.dart';
import 'photo_to_coloring_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _desbloqueado = false;
  bool _sorteando = false;
  late final String? _categoriaGratisMes;

  @override
  void initState() {
    super.initState();
    _categoriaGratisMes = FeaturedService.categoriaGratisDoMes();
    _carregarStatus();
  }

  Future<void> _carregarStatus() async {
    final status = await PurchaseService.estaDesbloqueado();
    if (mounted) setState(() => _desbloqueado = status);
  }

  Future<void> _mostrarDialogoDesbloqueio() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desbloquear tudo'),
        content: const Text(
          'Escolha como liberar todas as categorias premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await PurchaseService.ativarAssinatura();
              if (context.mounted) Navigator.pop(context);
              await _carregarStatus();
            },
            child: const Text('Assinar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await PurchaseService.desbloquearTudo();
              if (context.mounted) Navigator.pop(context);
              await _carregarStatus();
            },
            child: const Text('Compra única'),
          ),
        ],
      ),
    );
  }

  bool _categoriaEstaLiberada(Categoria categoria) {
    if (!categoria.premium) return true;
    if (_desbloqueado) return true;
    if (categoria.id == _categoriaGratisMes) return true;
    return false;
  }

  void _abrirCategoria(Categoria categoria) {
    if (!_categoriaEstaLiberada(categoria)) {
      _mostrarDialogoDesbloqueio();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GalleryScreen(categoria: categoria)),
    );
  }

  Future<void> _surpreendaMe() async {
    setState(() => _sorteando = true);
    try {
      final idsLiberados =
          categorias.where(_categoriaEstaLiberada).map((c) => c.id).toList();

      final todos = await AssetScanner.listarTodos(idsLiberados);

      if (!mounted) return;

      if (todos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ainda não há desenhos disponíveis para sortear.'),
          ),
        );
        return;
      }

      todos.shuffle();
      final escolhido = todos.first;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(desenho: escolhido)),
      );
    } finally {
      if (mounted) setState(() => _sorteando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomeCategoriaGratis = _categoriaGratisMes == null
        ? null
        : categorias.firstWhere((c) => c.id == _categoriaGratisMes).nome;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desenhos para Colorir'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _sorteando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.shuffle),
            tooltip: 'Surpreenda-me',
            onPressed: _sorteando ? null : _surpreendaMe,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favoritos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (nomeCategoriaGratis != null && !_desbloqueado)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Grátis este mês: $nomeCategoriaGratis!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Transformar foto em desenho'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PhotoToColoringScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          if (!_desbloqueado)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Desbloquear tudo'),
                  onPressed: _mostrarDialogoDesbloqueio,
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 16.0;
                  final cardWidth = (constraints.maxWidth - spacing) / 2;
                  final cardHeight = cardWidth / 1.1;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: spacing,
                    runSpacing: spacing,
                    children: categorias.map((categoria) {
                      final liberada = _categoriaEstaLiberada(categoria);
                      final gratisEsteMes =
                          categoria.id == _categoriaGratisMes &&
                              !_desbloqueado;
                      return SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _CategoriaCard(
                          categoria: categoria,
                          bloqueada: !liberada,
                          gratisEsteMes: gratisEsteMes,
                          onTap: () => _abrirCategoria(categoria),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final bool bloqueada;
  final bool gratisEsteMes;
  final VoidCallback onTap;

  const _CategoriaCard({
    required this.categoria,
    required this.bloqueada,
    required this.gratisEsteMes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(categoria.icone, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  categoria.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (bloqueada)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (gratisEsteMes)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Grátis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
