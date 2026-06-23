# Seuh

Aplicativo Android de penitências diárias desenvolvido em Flutter.

O Seuh sorteia uma penitência espiritual por dia para o usuário, incentivando práticas de mortificação, oração, caridade e disciplina cristã. O resultado é bloqueado até a meia-noite do dia seguinte, e uma notificação diária lembra o usuário de revelar sua nova penitência.

---

## Funcionalidades

- **Roleta diária** — sorteia uma penitência aleatória de um ciclo de 47 desafios, sem repetição até o ciclo se encerrar.
- **Bloqueio por data** — apenas um sorteio por dia; o resultado é restaurado ao reabrir o app.
- **Sequência (streak)** — contador de dias consecutivos que zera automaticamente se o usuário pular um dia.
- **Progresso do ciclo** — anel visual mostrando quantas penitências já foram concluídas no ciclo atual.
- **Histórico** — lista das últimas penitências realizadas.
- **Notificação à meia-noite** — lembrete diário para revelar a penitência do dia.
- **Som e vibração** — som de vento durante o spin e vibração a cada segundo, com carrilhão ao parar.
- **Filtro por categoria** — tela de listagem com filtro horizontal por tags (oração, jejum, caridade, etc.).

---

## Estrutura do projeto

```
lib/
├── main.dart                   # Ponto de entrada; inicializa notificações e Provider
├── app_state.dart              # Estado global via ChangeNotifier (progresso, streak, spin)
├── models/
│   └── penance.dart            # Modelo de dados da penitência
├── data/
│   └── penances_data.dart      # Mapa de cores de categorias e helpers de dificuldade
├── services/
│   ├── spin_audio.dart         # Síntese de som PCM em tempo real (vento + carrilhão)
│   └── notification_service.dart # Agendamento de notificação diária via flutter_local_notifications
├── screens/
│   ├── main_screen.dart        # Layout raiz com fundo, nuvens e barra de navegação
│   ├── home_screen.dart        # Tela inicial com roda de bússola e resultado
│   ├── progress_screen.dart    # Tela de progresso com anel, streak e histórico
│   └── penances_screen.dart    # Listagem de todas as penitências com filtro por categoria
├── widgets/
│   ├── compass_wheel.dart      # Roda de bússola animada
│   ├── floating_clouds.dart    # Nuvens flutuantes decorativas
│   ├── category_chip.dart      # Chips de filtro, badge de dificuldade e badge de categoria
│   ├── penance_card.dart       # Card de penitência na listagem
│   ├── progress_ring.dart      # Anel de progresso circular
│   └── name_modal.dart         # Modal de boas-vindas para o primeiro acesso
└── theme/
    └── pkb_theme.dart          # Cores, gradientes, tipografia e decorações do app

assets/
└── penances.json               # Lista de 47 penitências com nome, descrição, tags e dificuldade
```

---

## Penitências

As penitências ficam em `assets/penances.json` com a seguinte estrutura:

```json
{
  "penances": [
    {
      "id": 0,
      "nome": "Nome da Penitência",
      "descritivo": "Descrição detalhada do que deve ser feito.",
      "tags": ["categoria1", "categoria2"],
      "dificuldade": 2
    }
  ]
}
```

| Campo        | Tipo     | Descrição                                      |
|--------------|----------|------------------------------------------------|
| `id`         | int      | Identificador único                            |
| `nome`       | string   | Nome curto exibido na roleta e nos cards       |
| `descritivo` | string   | Instrução completa da penitência               |
| `tags`       | string[] | Categorias (ex: "oração", "jejum", "caridade") |
| `dificuldade`| int      | 1 = Leve · 2 = Média · 3 = Intensa            |

Para adicionar ou editar penitências, basta modificar o arquivo JSON e recompilar o app.

---

## Dependências principais

| Pacote                         | Uso                                              |
|--------------------------------|--------------------------------------------------|
| `provider`                     | Gerenciamento de estado com ChangeNotifier       |
| `shared_preferences`           | Persistência local (streak, histórico, spin date)|
| `audioplayers`                 | Reprodução de áudio PCM sintetizado em tempo real|
| `flutter_local_notifications`  | Notificação diária agendada à meia-noite         |
| `timezone`                     | Detecção de fuso horário para agendamento        |
| `google_fonts`                 | Fontes Quicksand e Nunito                        |

---

## Como compilar

### Pré-requisitos

- Flutter SDK instalado
- Android SDK configurado (`ANDROID_HOME`)
- JDK 21+

### Build de release

```bash
flutter build apk --release
```

O APK gerado fica em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Instalar via ADB

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## Observações técnicas

- **Som sintetizado em Dart** — nenhum arquivo de áudio externo; o som é gerado via filtros biquad (passa-baixa + passa-banda) aplicados sobre ruído branco, replicando o comportamento do Web Audio API do protótipo HTML original.
- **Fuso horário sem plugin nativo** — o fuso é detectado via `DateTime.now().timeZoneOffset`, evitando incompatibilidades de JVM com o pacote `flutter_timezone`.
- **Core library desugaring** — habilitado em `android/app/build.gradle.kts` para compatibilidade do `flutter_local_notifications` com APIs de data/hora modernas.
