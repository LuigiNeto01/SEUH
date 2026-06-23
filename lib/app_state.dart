import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/penance.dart';

/// Representa uma penitência concluída no histórico do usuário.
class HistoryItem {
  /// Data/hora da conclusão em formato legível (ex: "Agora mesmo").
  final String when;

  /// Nome da penitência concluída.
  final String name;

  HistoryItem({required this.when, required this.name});

  Map<String, dynamic> toJson() => {'when': when, 'name': name};

  factory HistoryItem.fromJson(Map<String, dynamic> j) =>
      HistoryItem(when: j['when'] as String, name: j['name'] as String);
}

/// Retorna a data atual no formato "YYYY-MM-DD", usado como chave de controle diário.
String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// Estado global do aplicativo Seuh, gerenciado via Provider.
///
/// Responsável por:
/// - Carregar as penitências do JSON de assets.
/// - Persistir e restaurar o progresso do usuário via SharedPreferences.
/// - Controlar o bloqueio diário de spin (apenas um por dia).
/// - Calcular e validar a sequência (streak) de dias consecutivos.
class AppState extends ChangeNotifier {
  /// Índice da tela ativa na barra de navegação inferior.
  int currentScreen = 0;

  /// Lista de penitências carregadas do assets/penances.json.
  List<Penance> penances = [];

  /// Indica se o estado inicial foi totalmente carregado.
  bool loaded = false;

  // ── Estado da roleta ──────────────────────────────────────────────────────

  /// Indica se a animação de spin está em andamento.
  bool spinning = false;

  /// Indica se o resultado do dia já foi revelado.
  bool revealed = false;

  /// Rotação acumulada da roda em graus (persiste entre sessões).
  double rotation = 0.0;

  /// Índice (id) da penitência sorteada atualmente.
  int? resultIdx;

  /// Indica se o usuário já girou a roleta hoje.
  bool spunToday = false;

  // ── Progresso ─────────────────────────────────────────────────────────────

  /// Número de dias consecutivos com penitência concluída.
  int streak = 0;

  /// Quantidade de penitências concluídas no ciclo atual.
  int completedThisCycle = 0;

  /// Total de penitências no ciclo (igual ao tamanho da lista do JSON).
  int cycleTotal = 0;

  /// IDs das penitências já sorteadas no ciclo atual (evita repetição).
  List<int> drawnIds = [];

  // ── Filtro de categorias ──────────────────────────────────────────────────

  /// Categoria ativa no filtro da tela de penitências.
  String activeCat = 'Todas';

  // ── Histórico ─────────────────────────────────────────────────────────────

  /// Lista das últimas penitências concluídas.
  List<HistoryItem> history = [];

  // ── Usuário ───────────────────────────────────────────────────────────────

  /// Nome do usuário salvo localmente.
  String? userName;

  /// Controla a exibição do modal de primeiro acesso.
  bool showNameModal = false;

  /// Data do último spin concluído (YYYY-MM-DD), usada para validar o streak.
  String? _lastSpinDate;

  AppState() {
    _init();
  }

  /// Inicializa o estado: carrega penitências do JSON e restaura dados persistidos.
  Future<void> _init() async {
    await _loadPenances();
    await _loadPersistedState();
    loaded = true;
    notifyListeners();
  }

  /// Carrega a lista de penitências do arquivo assets/penances.json.
  Future<void> _loadPenances() async {
    final jsonStr = await rootBundle.loadString('assets/penances.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    penances = (data['penances'] as List)
        .map((e) => Penance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Restaura o progresso salvo via SharedPreferences.
  ///
  /// Se o usuário já girou hoje, restaura o resultado sem permitir novo spin.
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    userName = prefs.getString('pkb_user_name');
    showNameModal = userName == null || userName!.isEmpty;

    streak = prefs.getInt('pkb_streak') ?? 0;
    completedThisCycle = prefs.getInt('pkb_completed') ?? 0;

    // O total do ciclo é sempre derivado do JSON, nunca do cache salvo.
    cycleTotal = penances.length;

    final drawnRaw = prefs.getString('pkb_drawn_ids');
    if (drawnRaw != null) {
      drawnIds = List<int>.from(json.decode(drawnRaw) as List);
    }

    final historyRaw = prefs.getString('pkb_history');
    if (historyRaw != null) {
      history = (json.decode(historyRaw) as List)
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    rotation = prefs.getDouble('pkb_rotation') ?? 0.0;

    // Verifica se o usuário já girou hoje para restaurar o resultado sem novo spin.
    _lastSpinDate = prefs.getString('pkb_last_spin_date');
    if (_lastSpinDate == _todayKey()) {
      spunToday = true;
      revealed = true;
      resultIdx = prefs.getInt('pkb_last_result_idx');
    } else {
      spunToday = false;
      revealed = false;
      resultIdx = null;
    }
  }

  /// Salva o estado atual no SharedPreferences.
  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pkb_streak', streak);
    await prefs.setInt('pkb_completed', completedThisCycle);
    await prefs.setString('pkb_drawn_ids', json.encode(drawnIds));
    await prefs.setString(
      'pkb_history',
      json.encode(history.map((h) => h.toJson()).toList()),
    );
    await prefs.setString('pkb_last_spin_date', _todayKey());
    await prefs.setDouble('pkb_rotation', rotation);
    if (resultIdx != null) {
      await prefs.setInt('pkb_last_result_idx', resultIdx!);
    }
  }

  /// Salva o nome do usuário e fecha o modal de boas-vindas.
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pkb_user_name', name);
    userName = name;
    showNameModal = false;
    notifyListeners();
  }

  /// Altera a tela ativa na navegação inferior.
  void setScreen(int idx) {
    currentScreen = idx;
    notifyListeners();
  }

  /// Altera o filtro de categoria na tela de penitências.
  void setActiveCat(String cat) {
    activeCat = cat;
    notifyListeners();
  }

  /// Calcula o resultado do próximo spin sem ainda aplicá-lo ao estado.
  ///
  /// Retorna (rotação alvo em graus, id da penitência sorteada).
  /// Prioriza penitências ainda não sorteadas no ciclo atual.
  (double, int) prepareSpinResult() {
    final rng = Random();
    final available = penances.where((p) => !drawnIds.contains(p.id)).toList();

    // Usa todas as penitências se o ciclo acabou de resetar.
    final pool = available.isEmpty ? penances : available;
    final chosen = pool[rng.nextInt(pool.length)];

    final extraSpins = 5 + rng.nextInt(4);
    final extraDeg = rng.nextInt(360);
    final target = rotation + extraSpins * 360.0 + extraDeg;

    return (target, chosen.id);
  }

  /// Marca o início da animação de spin.
  void startSpin() {
    spinning = true;
    revealed = false;
    notifyListeners();
  }

  /// Finaliza o spin: atualiza progresso, streak e persiste o resultado.
  ///
  /// O streak incrementa apenas se o último spin foi ontem ou hoje (reabertura).
  /// Se o usuário pulou um ou mais dias, o streak reinicia em 1.
  void finishSpin(double newRotation, int chosenId) {
    rotation = newRotation;
    resultIdx = chosenId;
    spinning = false;
    revealed = true;
    spunToday = true;

    // Adiciona à lista de sorteados se ainda não estiver.
    if (!drawnIds.contains(chosenId)) {
      drawnIds = [...drawnIds, chosenId];
    }

    completedThisCycle += 1;

    // Valida o streak: mantém a sequência apenas se o último spin foi ontem.
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    if (_lastSpinDate == null ||
        _lastSpinDate == yesterdayKey ||
        _lastSpinDate == _todayKey()) {
      streak += 1;
    } else {
      // Dia(s) pulado(s): reinicia a sequência.
      streak = 1;
    }
    _lastSpinDate = _todayKey();

    // Reseta o ciclo quando todas as penitências forem sorteadas.
    if (drawnIds.length >= penances.length) {
      drawnIds = [];
      completedThisCycle = 0;
    }

    final p = penances.firstWhere((p) => p.id == chosenId);
    history = [HistoryItem(when: 'Agora mesmo', name: p.nome), ...history];

    _persistState();
    notifyListeners();
  }

  /// Retorna a penitência do resultado atual, ou null se ainda não houver resultado.
  Penance? get resultPenance =>
      resultIdx != null
          ? penances.firstWhere((p) => p.id == resultIdx,
              orElse: () => penances.first)
          : null;

  /// Quantidade de penitências restantes até o fim do ciclo.
  int get remaining => cycleTotal - completedThisCycle;

  /// Lista de penitências filtradas pela categoria ativa.
  List<Penance> get filteredPenances {
    if (activeCat == 'Todas') return penances;
    return penances.where((p) => p.tags.contains(activeCat)).toList();
  }

  /// Verifica se uma penitência já foi sorteada no ciclo atual.
  bool isDrawn(int id) => drawnIds.contains(id);

  /// Retorna todas as categorias/tags únicas presentes nas penitências, com "Todas" no início.
  List<String> get allCategories {
    final tags = penances.expand((p) => p.tags).toSet().toList()..sort();
    return ['Todas', ...tags];
  }
}
