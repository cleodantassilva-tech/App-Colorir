/// Representa um desenho disponível para impressão.
class Desenho {
  final String id;
  final String titulo;
  final String categoria;
  final String caminhoArquivo; // caminho do PDF/imagem dentro de assets/
  final String thumbnail; // caminho da miniatura (pode ser o mesmo arquivo)

  const Desenho({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.caminhoArquivo,
    required this.thumbnail,
  });
}

/// Representa uma categoria de desenhos (ex: Animais, Dinossauros).
class Categoria {
  final String id;
  final String nome;
  final String icone; // emoji ou caminho de ícone

  const Categoria({
    required this.id,
    required this.nome,
    required this.icone,
  });
}
