import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:arvind_party/arvind_party_web/lib/core/constants/staff_management_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/owner/views/coin_generation_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/auth/views/staff_login_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/owner/views/audit_logs_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/users/views/user_management_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/dashboard/views/dashboard_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/rooms/views/room_management_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/settings/views/settings_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/agency/views/agency_management_view.dart';
import 'package:arvind_party/arvind_party_web/lib/modules/withdrawals/views/withdrawal_management_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // Backend aur Web ke connection ka entry point
  runApp(const ArvindPartyWebAdmin());
}

class ArvindPartyWebAdmin extends StatelessWidget {
  const ArvindPartyWebAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arvind Party - Owner Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF15141F),
        primaryColor: const Color(0xFFFF8906),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: GetStorage().read('staff_token') != null
          ? const AdminDashboard()
          : const StaffLoginView(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  late List<String> _menuItems;
  late List<IconData> _menuIcons;
  late String _userRole;

  @override
  void initState() {
    super.initState();
    _userRole = GetStorage().read('staff_role') ?? 'STAFF';
    _initMenu();
  }

  void _initMenu() {
    bool isOwner = _userRole == 'OWNER.WEB';

    // Owner ke alawa baaki sabke liye restricted items hide kar diye gaye hain
    _menuItems = [
      'Dashboard',
      if (isOwner) 'Staff Management',
      if (isOwner) 'Coin Generation',
      if (isOwner) 'Audit Logs',
      if (isOwner) 'Withdrawals',
      'User Management',
      'Room Management',
      'Agency Control',
      'System Settings'
    ];

    _menuIcons = [
      Icons.dashboard,
      if (isOwner) Icons.people_outline,
      if (isOwner) Icons.monetization_on_outlined,
      if (isOwner) Icons.receipt_long_outlined,
      if (isOwner) Icons.payments_outlined,
      Icons.manage_accounts_outlined,
      Icons.meeting_room_outlined,
      Icons.business_outlined,
      Icons.settings_outlined,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ─── LEFT SIDEBAR (NAVIGATION DRAWER) ───
          Container(
            width: 260,
            color: Colors.black,
            child: Column(
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  child: Text(
                    'ARVIND PARTY\nCONTROL CENTER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFF8906),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      // Highlight Coin Generation specially for Owner
                      final isCoinGen = _menuItems[index] == 'Coin Generation';

                      return ListTile(
                        leading: Icon(
                          _menuIcons[index],
                          color: isSelected
                              ? const Color(0xFFFF8906)
                              : (isCoinGen ? Colors.yellow : Colors.white54),
                        ),
                        title: Text(
                          _menuItems[index],
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFFF8906)
                                : (isCoinGen ? Colors.yellow : Colors.white54),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        tileColor: isSelected
                            ? Colors.white.withOpacity(0.05)
                            : Colors.transparent,
                        onTap: () {
                          setState(() => _selectedIndex = index);
                        },
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout',
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    GetStorage().remove('staff_token');
                    GetStorage().remove('staff_role');
                    Get.offAll(() => const StaffLoginView());
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ─── MAIN CONTENT AREA ───
          Expanded(
            child: Column(
              children: [
                // Top App Bar Header
                Container(
                  height: 70,
                  color: const Color(0xFF15141F),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _menuItems[_selectedIndex],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            _userRole,
                            style: const TextStyle(
                                color: Color(0xFFFF8906),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          CircleAvatar(
                            backgroundColor:
                                const Color(0xFFFF8906).withOpacity(0.2),
                            child: const Icon(Icons.person,
                                color: Color(0xFFFF8906)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Dynamic View
                Expanded(child: _buildContentView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    final currentMenu = _menuItems[_selectedIndex];

    switch (currentMenu) {
      case 'Dashboard':
        return const DashboardView();
      case 'Staff Management':
        return const StaffManagementView();
      case 'Coin Generation':
        return const CoinGenerationView();
      case 'Audit Logs':
        return const AuditLogsView();
      case 'Withdrawals':
        return const WithdrawalManagementView();
      case 'User Management':
        return const UserManagementView();
      case 'Room Management':
        return const RoomManagementView();
      case 'Agency Control':
        return const AgencyManagementView();
      case 'System Settings':
        return const SettingsView();
      default:
        return Center(
          child: Text('$currentMenu Module\nComing Soon',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 20)),
        );
    }
  }
}
