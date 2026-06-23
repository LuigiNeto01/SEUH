import 'package:flutter/material.dart';

/// Mapa de cores associadas a cada categoria/tag de penitência.
///
/// Usado nos chips de categoria para diferenciação visual.
const Map<String, Color> kCatColors = {
  'Saúde': Color(0xFF7FCBB0),
  'Social': Color(0xFF8FB8F0),
  'Produtividade': Color(0xFF86C4DE),
  'Coragem': Color(0xFFEFC06A),
  'Autocuidado': Color(0xFFB5A4E8),
  'Engraçado': Color(0xFFF0AE5E),
  'Desconexão': Color(0xFFB5A4E8),
  'Hidratação': Color(0xFF7FCBB0),
  'Conexão': Color(0xFF8FB8F0),
  'Organização': Color(0xFF86C4DE),
  'Ação': Color(0xFFEFC06A),
  'Meditação': Color(0xFFB5A4E8),
  'Exercício': Color(0xFF7FCBB0),
  'Emoção': Color(0xFFB5A4E8),
  'Movimento': Color(0xFF7FCBB0),
  'Digital': Color(0xFF86C4DE),
  'Novidade': Color(0xFFEFC06A),
  'Reflexão': Color(0xFFB5A4E8),
  'Leveza': Color(0xFFF0AE5E),
};

/// Retorna a cor da categoria informada. Usa azul padrão se a categoria não estiver mapeada.
Color catColor(String cat) => kCatColors[cat] ?? const Color(0xFF8FB8F0);

/// Retorna o rótulo textual do nível de dificuldade.
///
/// - 1 → "Leve"
/// - 2 → "Média"
/// - 3 → "Intensa"
String diffLabel(int diff) {
  switch (diff) {
    case 1:
      return 'Leve';
    case 2:
      return 'Média';
    case 3:
      return 'Intensa';
    default:
      return 'Leve';
  }
}

/// Retorna a cor associada ao nível de dificuldade.
///
/// - 1 → verde suave
/// - 2 → dourado
/// - 3 → laranja-salmão
Color diffColor(int diff) {
  switch (diff) {
    case 1:
      return const Color(0xFF7FCBB0);
    case 2:
      return const Color(0xFFEFC06A);
    case 3:
      return const Color(0xFFE89A7F);
    default:
      return const Color(0xFF7FCBB0);
  }
}
