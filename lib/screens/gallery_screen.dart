import 'package:flutter/material.dart';
import '../models/desenho.dart';
import '../services/asset_scanner.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  final Categoria categoria;
  const GalleryScreen({super.key, required this.categoria});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoria.nome)),
      body: FutureBuilder<List<Desenho>>(
        future: AssetScanner.listarPorCategoria(widget.categoria.id),
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
              if (todos.length > 6)
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
                          return _DesenhoThumbnail(desenho: desenho);
                        },
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
  const _DesenhoThumbnail({required this.desenho});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(desenho: desenho)),
        );
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
