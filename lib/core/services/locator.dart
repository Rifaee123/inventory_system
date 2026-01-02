import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_inventory_repository.dart';
import '../../data/repositories/supabase_order_repository.dart';
import '../../data/repositories/supabase_dashboard_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import 'profit_calculator_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Supabase Client
  // Supabase.initialize is called in main.dart
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // Repositories
  getIt.registerLazySingleton<InventoryRepository>(
    () => SupabaseInventoryRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => SupabaseOrderRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => SupabaseDashboardRepository(getIt<SupabaseClient>()),
  );

  // Using MockAuthRepository to bypass auth
  getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());

  // Services
  getIt.registerLazySingleton<ProfitCalculatorService>(
    () => ProfitCalculatorService(),
  );
}
