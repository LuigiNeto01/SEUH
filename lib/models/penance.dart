/// Representa uma penitência carregada do arquivo assets/penances.json.
class Penance {
  /// Identificador único da penitência.
  final int id;

  /// Nome curto exibido na roleta e nos cards.
  final String nome;

  /// Descrição completa com as instruções da penitência.
  final String descritivo;

  /// Lista de categorias/tags associadas à penitência.
  final List<String> tags;

  /// Nível de dificuldade: 1 = Leve, 2 = Média, 3 = Intensa.
  final int dificuldade;

  const Penance({
    required this.id,
    required this.nome,
    required this.descritivo,
    required this.tags,
    required this.dificuldade,
  });

  // Aliases em inglês mantidos para compatibilidade com widgets existentes.
  String get name => nome;
  String get desc => descritivo;

  /// Retorna a primeira tag como categoria principal (fallback vazio se não houver tags).
  String get cat => tags.isNotEmpty ? tags[0] : '';
  int get diff => dificuldade;

  /// Cria uma [Penance] a partir de um mapa JSON.
  factory Penance.fromJson(Map<String, dynamic> json) => Penance(
        id: json['id'] as int,
        nome: json['nome'] as String,
        descritivo: json['descritivo'] as String,
        tags: List<String>.from(json['tags'] as List),
        dificuldade: json['dificuldade'] as int,
      );
}
