import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/locator.dart';
import 'core/router/app_router.dart';
import 'core/constants/supabase_constants.dart';
import 'domain/repositories/auth_repository.dart';
import 'modules/auth/interactor/auth_bloc.dart';
import 'modules/auth/interactor/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(getIt<AuthRepository>())..add(AuthCheckRequested()),
      child: MaterialApp.router(
        title: 'Inventory System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1313EC)),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
