import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../modules/auth/interactor/auth_bloc.dart';
import '../../modules/auth/interactor/auth_event.dart';
import '../../modules/auth/interactor/auth_state.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final location = GoRouterState.of(context).uri.toString();
        final isDashboard = location.startsWith('/dashboard');
        final isInventory = location.startsWith('/inventory');
        final isOrders = location.startsWith('/orders');
        final isAnalytics = location.startsWith('/analytics');

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF6F6F8),
          drawer: MediaQuery.of(context).size.width < 900
              ? _buildDrawer(
                  context,
                  isDashboard,
                  isInventory,
                  isOrders,
                  isAnalytics,
                  authState,
                )
              : null,
          body: Column(
            children: [
              // Top Navigation Header
              Container(
                height: 64,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFE7E7F3)),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 900;

                    if (isMobile) {
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            color: const Color(0xFF1313EC),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.inventory_2,
                            color: Color(0xFF1313EC),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'StitchInventory',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D0D1B),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          _buildProfileAvatar(context, authState),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          color: Color(0xFF1313EC),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'StitchInventory',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D0D1B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 400,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7E7F3).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Color(0xFF4C4C9A),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            'Search by SKU, product name...',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF4C4C9A),
                                          fontSize: 13,
                                        ),
                                        isDense: true,
                                      ),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _NavLink(
                              label: 'Dashboard',
                              isActive: isDashboard,
                              onTap: () => context.go('/dashboard'),
                            ),
                            const SizedBox(width: 24),
                            _NavLink(
                              label: 'Inventory',
                              isActive: isInventory,
                              onTap: () => context.go('/inventory'),
                            ),
                            const SizedBox(width: 24),
                            _NavLink(
                              label: 'Orders',
                              isActive: isOrders,
                              onTap: () => context.go('/orders'),
                            ),
                            const SizedBox(width: 24),
                            _NavLink(
                              label: 'Analytics',
                              isActive: isAnalytics,
                              onTap: () => context.go('/analytics'),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        _buildProfileAvatar(context, authState),
                      ],
                    );
                  },
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(BuildContext context, AuthState authState) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == 'logout') {
          context.read<AuthBloc>().add(SignOutRequested());
          context.go('/login');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authState.user?.username ?? 'Guest User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                authState.user?.role.name.toUpperCase() ?? 'NONE',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Divider(),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1313EC).withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E7F3)),
        ),
        child: Center(
          child: Text(
            (authState.user?.username ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF1313EC),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    bool isDashboard,
    bool isInventory,
    bool isOrders,
    bool isAnalytics,
    AuthState authState,
  ) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1313EC), Color(0xFF4C4CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.inventory_2, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  'StitchInventory',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard,
              color: isDashboard ? const Color(0xFF1313EC) : Colors.grey[700],
            ),
            title: Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: isDashboard ? FontWeight.bold : FontWeight.normal,
                color: isDashboard ? const Color(0xFF1313EC) : Colors.grey[700],
              ),
            ),
            onTap: () {
              context.go('/dashboard');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.inventory,
              color: isInventory ? const Color(0xFF1313EC) : Colors.grey[700],
            ),
            title: Text(
              'Inventory',
              style: TextStyle(
                fontWeight: isInventory ? FontWeight.bold : FontWeight.normal,
                color: isInventory ? const Color(0xFF1313EC) : Colors.grey[700],
              ),
            ),
            onTap: () {
              context.go('/inventory');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.receipt_long,
              color: isOrders ? const Color(0xFF1313EC) : Colors.grey[700],
            ),
            title: Text(
              'Orders',
              style: TextStyle(
                fontWeight: isOrders ? FontWeight.bold : FontWeight.normal,
                color: isOrders ? const Color(0xFF1313EC) : Colors.grey[700],
              ),
            ),
            onTap: () {
              context.go('/orders');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.analytics,
              color: isAnalytics ? const Color(0xFF1313EC) : Colors.grey[700],
            ),
            title: Text(
              'Analytics',
              style: TextStyle(
                fontWeight: isAnalytics ? FontWeight.bold : FontWeight.normal,
                color: isAnalytics ? const Color(0xFF1313EC) : Colors.grey[700],
              ),
            ),
            onTap: () {
              context.go('/analytics');
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              context.read<AuthBloc>().add(SignOutRequested());
              context.go('/login');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? const Color(0xFF1313EC) : const Color(0xFF0D0D1B),
        ),
      ),
    );
  }
}
