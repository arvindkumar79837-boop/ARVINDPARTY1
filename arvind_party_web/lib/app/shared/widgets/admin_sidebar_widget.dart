import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/controllers/role_auth_controller.dart'; // अपने कंट्रोलर का सही पाथ दें

class AdminSidebarWidget extends StatelessWidget {
  final RoleAuthController authController = Get.find<RoleAuthController>();

  AdminSidebarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: 260,
        height: double.infinity,
        color: const Color(0xFF1E1E2E), // प्रीमियम डार्क थीम बैकग्राउंड
        child: Column(
          children: [
            // शीर्ष ब्रांडिंग / लोगो एरिया
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF2D2D44))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ARVIND PARTY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        authController.currentUserRole.value.name.toUpperCase().replaceAll('WEB', ' PANEL'),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // साइडबार मेनू लिस्ट (परमिशन के हिसाब से डायनामिक)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    show: true, // डैशबोर्ड सबको दिखेगा
                    onTap: () => Get.toNamed('/dashboard'),
                  ),
                  
                  _buildMenuItem(
                    icon: Icons.monetization_on,
                    title: "Coin Generator",
                    show: authController.hasPermission('COIN_GEN'), // सिर्फ ओनर को दिखेगा
                    onTap: () => Get.toNamed('/coin-generation'),
                  ),

                  _buildMenuItem(
                    icon: Icons.swap_horizontal_circle,
                    title: "Coin Transfer",
                    show: authController.hasPermission('COIN_TRANSFER'),
                    onTap: () => Get.toNamed('/coin-transfer'),
                  ),

                  _buildMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: "Withdrawal Approvals",
                    show: authController.hasPermission('WITHDRAW_APPROVAL'),
                    onTap: () => Get.toNamed('/withdrawals'),
                  ),

                  _buildMenuItem(
                    icon: Icons.people,
                    title: "Staff Invitation",
                    show: authController.hasPermission('STAFF_MGT'), // ओनर के लिए रोल असाइनमेंट
                    onTap: () => Get.toNamed('/admin-roles'),
                  ),

                  _buildMenuItem(
                    icon: Icons.view_carousel,
                    title: "Banner Management",
                    show: authController.hasPermission('BANNER'),
                    onTap: () => Get.toNamed('/announcements'),
                  ),

                  _buildMenuItem(
                    icon: Icons.card_giftcard,
                    title: "Frames & Entry Effects",
                    show: authController.hasPermission('GIVE_FRAME'),
                    onTap: () => Get.toNamed('/rewards'),
                  ),

                  _buildMenuItem(
                    icon: Icons.business,
                    title: "Agency Center",
                    show: authController.hasPermission('AGENCY'),
                    onTap: () => Get.toNamed('/agencies'),
                  ),

                  _buildMenuItem(
                    icon: Icons.games,
                    title: "Dynamic Game Center",
                    show: authController.hasPermission('ADD_GAME'), // खुद का या रेंटेड गेम जोड़ने के लिए
                    onTap: () => Get.toNamed('/system'),
                  ),

                  _buildMenuItem(
                    icon: Icons.block,
                    title: "Ban Management",
                    show: authController.hasPermission('BAN_USER'),
                    onTap: () => Get.toNamed('/bans'),
                  ),

                  _buildMenuItem(
                    icon: Icons.lock,
                    title: "Password Settings",
                    show: !authController.permissions.isPasswordLocked.value, // अगर लॉक्ड है तो गायब रहेगा
                    onTap: () => Get.toNamed('/settings'),
                  ),
                ],
              ),
            ),

            // नीचे लॉगआउट और यूज़र प्रोफाइल कार्ड
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF2D2D44))),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authController.userName.value.isEmpty ? "Admin User" : authController.userName.value,
                      style: const TextStyle(color: Colors.white, fontSize: 14, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      // लॉगआउट लॉजिक
                      Get.offAllNamed('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// साइडबार आइटम बनाने का हेल्पर विजेट
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool show,
    required VoidCallback onTap,
  }) {
    if (!show) return const SizedBox.shrink(); // अगर परमिशन नहीं है, तो हवा में गायब कर दो

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF9E9E9E) == const Color(0xFF9E9E9E) ? const Color(0xFFA0A0C0) : Colors.orange),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
        hoverColor: Colors.orange.withOpacity(0.1),
      ),
    );
  }
}