import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/photo_to_coloring_service.dart';
import '../services/print_service.dart';

class PhotoToColoringScreen extends StatefulWidget {
  const PhotoToColoringScreen({super.key});

  @override
  State<PhotoToColoringScreen> createState() => _PhotoToColoringScreenState();
}

class _PhotoToColoringScreenState extends State<PhotoToColoringScreen> {
  Uint8List? _resultado;
  bool _processando = false;
  bool _imprimindo = false;
  String? _erro;
  
  // NOVO: Controlador para ler o nome que o usuário digitar
  final TextEditingController _nomeController = TextEditingController();

  // (Mantenha o seu _escolherFoto exatamente como estava)
  Future<void> _escolherFoto() async {
    setState(() => _erro = null);

    final picker = ImagePicker();
    final XFile? arquivo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (arquivo == null) return;

    setState(() => _processando = true);
    try {
      final bytesOriginais = await arquivo.readAsBytes();
      final resultado = PhotoToColoringService.converterParaDesenho(
        bytesOriginais,
      );
      setState(() => _resultado = resultado);
    } catch (e) {
      setState(() => _erro = 'Não foi possível processar essa foto.');
    } finally {
      setState(() => _processando = false);
    }
  }

  // (Atualizamos o _imprimir para enviar o nome)
  Future<void> _imprimir() async {
    if (_resultado == null) return;
    setState(() => _imprimindo = true);
    try {
      await PrintService.imprimirImagem(
        bytesImagem: _resultado!,
        nomeDocumento: 'Foto para Colorir',
        // NOVO: Envia o nome digitado para o arquivo de impressão
        nomeCrianca: _nomeController.text.trim(), 
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
  void dispose() {
    _nomeController.dispose(); // Limpa a memória quando sair da tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto para Desenho')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_erro!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: Center(
                child: _processando
                    ? const CircularProgressIndicator()
                    : _resultado != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_resultado!, fit: BoxFit.contain),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.photo_camera_back, size: 80, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'Dica: Roupas sem estampa e fotos bem iluminadas\ngeram desenhos muito mais limpos!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Escolher foto'),
                onPressed: _processando ? null : _escolherFoto,
              ),
            ),
            if (_resultado != null) ...[
              const SizedBox(height: 16),
              
              // NOVO: Campo de texto para o nome da criança
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da criança (Opcional)',
                  hintText: 'Ex: Miguel',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
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
            ],
          ],
        ),
      ),
    );
  }
}
