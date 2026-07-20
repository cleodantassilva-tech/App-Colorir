import '../models/desenho.dart';

/// Lista de categorias exibidas na Home.
/// Substitua/adicione conforme suas categorias reais.
const List<Categoria> categorias = [
  Categoria(id: 'animais', nome: 'Animais', icone: '🐶'),
  Categoria(id: 'dinossauros', nome: 'Dinossauros', icone: '🦕'),
  Categoria(id: 'veiculos', nome: 'Veículos', icone: '🚗'),
  Categoria(id: 'jardim', nome: 'Jardim', icone: '🌷', premium: true),
  Categoria(id: 'dragao', nome: 'Dragão', icone: '🐉', premium: true),
  Categoria(id: 'monster_truck', nome: 'Monster Truck', icone: '🚚', premium: true),
  Categoria(id: 'datas_comemorativas', nome: 'Datas Comemorativas', icone: '🎉'),
];

/// Lista de desenhos de exemplo.
/// Em produção, isso pode vir de um JSON local, de um Firestore,
/// ou ser gerado automaticamente lendo os arquivos da pasta assets/.
final List<Desenho> desenhosExemplo = [
  const Desenho(
    id: 'animal_01',
    titulo: 'Cachorro Feliz',
    categoria: 'animais',
    caminhoArquivo: 'assets/categorias/animais/cachorro_feliz.pdf',
    thumbnail: 'assets/categorias/animais/cachorro_feliz_thumb.png',
  ),
  const Desenho(
    id: 'dino_01',
    titulo: 'Tiranossauro',
    categoria: 'dinossauros',
    caminhoArquivo: 'assets/categorias/dinossauros/tiranossauro.pdf',
    thumbnail: 'assets/categorias/dinossauros/tiranossauro_thumb.png',
  ),
  const Desenho(
    id: 'veiculo_01',
    titulo: 'Carro de Corrida',
    categoria: 'veiculos',
    caminhoArquivo: 'assets/categorias/veiculos/carro_corrida.pdf',
    thumbnail: 'assets/categorias/veiculos/carro_corrida_thumb.png',
  ),
];

List<Desenho> desenhosPorCategoria(String categoriaId) {
  return desenhosExemplo.where((d) => d.categoria == categoriaId).toList();
}
