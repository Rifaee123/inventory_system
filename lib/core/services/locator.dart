import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/inventory/data/repositories/supabase_inventory_repository.dart';
import '../../modules/orders/data/repositories/supabase_order_repository.dart';
import '../../modules/dashboard/data/repositories/supabase_dashboard_repository.dart';
import '../../modules/inventory/domain/repositories/inventory_repository.dart';
import '../../modules/orders/domain/repositories/order_repository.dart';
import '../../modules/dashboard/domain/repositories/dashboard_repository.dart';
import '../../modules/auth/domain/repositories/auth_repository.dart';
import 'profit_calculator_service.dart';
import 'storage_service.dart';
import '../../modules/auth/data/repositories/supabase_auth_repository.dart';
import '../../modules/inventory/data/repositories/supabase_category_repository.dart';
import '../../modules/inventory/domain/repositories/category_repository.dart';

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

  // Using SupabaseAuthRepository for real auth
  getIt.registerLazySingleton<AuthRepository>(
    () => SupabaseAuthRepository(getIt<SupabaseClient>()),
  );

  // Services
  getIt.registerLazySingleton<ProfitCalculatorService>(
    () => ProfitCalculatorService(),
  );

  getIt.registerLazySingleton<StorageService>(
    () => SupabaseStorageService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => SupabaseCategoryRepository(getIt<SupabaseClient>()),
  );
}
