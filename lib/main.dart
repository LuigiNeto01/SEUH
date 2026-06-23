import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'theme/pkb_theme.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';

/// Ponto de entrada do aplicativo Seuh.
///
/// Inicializa as notificações antes de montar a árvore de widgets.
/// O erro de notificação é capturado para não travar o app caso a permissão
/// seja negada ou o sistema não suporte o recurso.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Força orientação retrato para garantir layout correto em todos os dispositivos.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await NotificationService.init();
  } catch (_) {
    // Falha silenciosa: o app funciona normalmente sem notificações.
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const PkbApp(),
    ),
  );
}

/// Widget raiz do aplicativo.
class PkbApp extends StatelessWidget {
  const PkbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seuh',
      debugShowCheckedModeBanner: false,
      theme: PkbTheme.theme,
      home: const MainScreen(),
    );
  }
}
