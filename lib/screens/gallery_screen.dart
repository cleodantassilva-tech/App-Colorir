import 'package:flutter/material.dart';
import '../models/desenho.dart';
import '../services/asset_scanner.dart';
import '../services/print_service.dart';
import '../widgets/paper_size_dialog.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  final Categoria categoria;
  const GalleryScreen({super.key, required this.categoria});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _busca = '';
  bool _modoSelecao = false;
  final Set<String> _selecionados = {};
  bool _imprimindoVarios = false;
  late Future<List<Desenho>> _desenhosFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a busca dos desenhos apenas uma vez ao abrir a tela
    // Isso impede que o teclado feche a cada letra digitada na barra de pesquisa
    _desenhosFuture = AssetScanner.listarPorCategoria(widget.categoria.id);
  }

  void _alternarModoSelecao() {
    setState(() {
      _modoSelecao = !_modoSelecao;
      _selecionados.clear();
    });
  }

  void _alternarSelecionado(Desenho desenho) {
    setState(() {
      if (_selecionados.contains(desenho.id)) {
        _selecionados.remove(desenho.id);
      } else {
        _selecionados.add(desenho.id);
      }
    });
  }

  Future<void> _imprimirSelecionados(List<Desenho> todos) async {
    final selecionados =
        todos.where((d) => _selecionados.contains(d.id)).toList();
    if (selecionados.isEmpty) return;

    final formato = await escolherTamanhoPapel(context);
    if (formato == null) return;

    setState(() => _imprimindoVarios = true);
    try {
      await PrintService.imprimirVarios(
        caminhosAssets: selecionados.map((d) => d.caminhoArquivo).toList(),
        nomeDocumento: '${widget.categoria.nome} - Selecionados',
        formato: formato,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao imprimir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _imprimindoVarios = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria.nome),
        actions: [
          IconButton(
            icon: Icon(_modoSelecao ? Icons.close : Icons.checklist),
            tooltip: _modoSelecao ? 'Cancelar seleção' : 'Selecionar vários',
            onPressed: _alternarModoSelecao,
          ),
        ],
      ),
      body: FutureBuilder<List<Desenho>>(
        future: _desenhosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snapshot.data ?? [];
          final filtrados = _busca.isEmpty
              ? todos
              : todos
                  .where((d) =>
                      d.titulo.toLowerCase().contains(_busca.toLowerCase()))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar desenho...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (valor) => setState(() => _busca = valor),
                ),
              ),
              Expanded(
                child: filtrados.isEmpty
                    ? const Center(child: Text('Nenhum desenho encontrado.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          final desenho = filtrados[index];
                          final selecionado =
                              _selecionados.contains(desenho.id);
                          return _DesenhoThumbnail(
                            desenho: desenho,
                            modoSelecao: _modoSelecao,
                            selecionado: selecionado,
                            onTap: () {
                              if (_modoSelecao) {
                                _alternarSelecionado(desenho);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(desenho: desenho),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
              if (_modoSelecao && _selecionados.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: _imprimindoVarios
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.print),
                      label: Text(_imprimindoVarios
                          ? 'Abrindo impressão...'
                          : 'Imprimir selecionados (${_selecionados.length})'),
                      onPressed: _imprimindoVarios
                          ? null
                          : () => _imprimirSelecionados(todos),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DesenhoThumbnail extends StatelessWidget {
  final Desenho desenho;
  final bool modoSelecao;
  final bool selecionado;
  final VoidCallback onTap;

  const _DesenhoThumbnail({
    required this.desenho,
    required this.modoSelecao,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    desenho.thumbnail,
                    fit: BoxFit.cover,
                    width: double.infinity,
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
          if (modoSelecao)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                selecionado ? Icons.check_circle : Icons.circle_outlined,
                color: selecionado ? Colors.green : Colors.white,
                size: 26,
              ),
            ),
        ],
      ),
    );
  }
}
