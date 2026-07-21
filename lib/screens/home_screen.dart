import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/desenho.dart';
import '../services/purchase_service.dart';
import 'favorites_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _desbloqueado = false;

  @override
  void initState() {
    super.initState();
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
          'Libere todas as categorias premium com uma única compra.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await PurchaseService.desbloquearTudo();
              if (context.mounted) Navigator.pop(context);
              await _carregarStatus();
            },
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  void _abrirCategoria(Categoria categoria) {
    if (categoria.premium && !_desbloqueado) {
      _mostrarDialogoDesbloqueio();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GalleryScreen(categoria: categoria)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desenhos para Colorir'),
        centerTitle: true,
        actions: [
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
          if (!_desbloqueado)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                      final bloqueada =
                          categoria.premium && !_desbloqueado;
                      return SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _CategoriaCard(
                          categoria: categoria,
                          bloqueada: bloqueada,
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
  final VoidCallback onTap;

  const _CategoriaCard({
    required this.categoria,
    required this.bloqueada,
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
