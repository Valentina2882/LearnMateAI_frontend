import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/horarios_provider.dart';
import 'providers/examenes_provider.dart';
import 'providers/bienestar_provider.dart';
import 'providers/kora_ia_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'config/app_colors.dart';
import 'config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno desde el archivo .env
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Variables de entorno cargadas correctamente');
  } catch (e) {
    print('⚠️ ADVERTENCIA: No se pudo cargar el archivo .env: $e');
    print('   Asegúrate de que el archivo .env existe en la raíz del proyecto frontend');
  }
  
  // Inicializar Supabase con las variables de entorno
  final supabaseUrl = ApiConfig.supabaseUrl;
  final supabaseAnonKey = ApiConfig.supabaseAnonKey;
  
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('✅ Supabase inicializado correctamente');
  } else {
    print('⚠️ ADVERTENCIA: Supabase no está configurado correctamente.');
    print('   Verifica que SUPABASE_URL y SUPABASE_KEY estén en el archivo .env');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthProvider()),
            ChangeNotifierProvider(create: (context) => HorariosProvider()),
            ChangeNotifierProvider(create: (context) => ExamenesProvider()),
            ChangeNotifierProvider(create: (context) => BienestarProvider()),
            ChangeNotifierProvider(create: (context) => KoraIAProvider()),
          ],
      child: MaterialApp(
        title: 'LearnMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.azulOscuro,
            primary: AppColors.azulOscuro,
            secondary: AppColors.celeste,
            tertiary: AppColors.verdeAzulado,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializar el estado de autenticación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mostrar loading mientras se inicializa
        if (authProvider.isLoading && !authProvider.isAuthenticated) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando...'),
                ],
              ),
            ),
          );
        }

        // Navegar según el estado de autenticación
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

