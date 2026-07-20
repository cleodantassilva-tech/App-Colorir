import '../models/desenho.dart';

const List<Categoria> categorias = [
  Categoria(id: 'animais', nome: 'Animais', icone: '🐶'),
  Categoria(id: 'dinossauros', nome: 'Dinossauros', icone: '🦕'),
  Categoria(id: 'veiculos', nome: 'Veículos', icone: '🚗'),
  Categoria(id: 'datas_comemorativas', nome: 'Datas Comemorativas', icone: '🎉'),
  Categoria(id: 'princesas', nome: 'Princesas', icone: '👑', premium: true),
  Categoria(id: 'unicornio', nome: 'Unicórnio', icone: '🦄', premium: true),
  Categoria(id: 'gatinhos', nome: 'Gatinhos', icone: '🐱', premium: true),
  Categoria(id: 'pandinhas', nome: 'Pandinhas', icone: '🐼', premium: true),
  Categoria(id: 'cristao', nome: 'Cristão', icone: '✝️', premium: true),
  Categoria(id: 'animais_bosque', nome: 'Animais do Bosque', icone: '🦔', premium: true),
  Categoria(id: 'doces_fofos', nome: 'Doces Fofos', icone: '🍭', premium: true),
  Categoria(id: 'cactus', nome: 'Cactus', icone: '🌵', premium: true),
  Categoria(id: 'raposinha', nome: 'Raposinha', icone: '🦊', premium: true),
  Categoria(id: 'monstros_fofos', nome: 'Monstros Fofos', icone: '🦖', premium: true),
  Categoria(id: 'jardim', nome: 'Jardim', icone: '🌷', premium: true),
  Categoria(id: 'dragao', nome: 'Dragão', icone: '🐉', premium: true),
  Categoria(id: 'monster_truck', nome: 'Monster Truck', icone: '🚚', premium: true),
  Categoria(id: 'outros', nome: 'Outros', icone: '✨', premium: true),
];

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
