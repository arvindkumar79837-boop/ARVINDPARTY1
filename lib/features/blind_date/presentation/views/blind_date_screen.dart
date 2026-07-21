import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/blind_date_controller.dart';

class BlindDateScreen extends StatelessWidget {
  const BlindDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BlindDateController>();
    return Obx(() {
      if (ctrl.isCallActive.value) {
        return _buildSearchingOrCallView(ctrl);
      }
      if (ctrl.match.value != null && ctrl.session.value != null) {
        return _buildSessionView(ctrl);
      }
      return _buildMainView(ctrl);
    });
  }

  Widget _buildMainView(BlindDateController ctrl) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0033), Color(0xFF0D001A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.favorite, size: 80, color: Color(0xFFFF6B9D)),
              const SizedBox(height: 12),
              const Text(
                'Blind Date',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Meet someone special anonymously',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              const SizedBox(height: 32),
              _preferencesCard(ctrl),
              const SizedBox(height: 20),
              if (ctrl.errorMessage.value.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ctrl.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ]),
                ),
              const SizedBox(height: 20),
              _searchButton(ctrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preferencesCard(BlindDateController ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferences', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // Gender preference
          const Text('Looking for', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _chip('Any', 'ANY', ctrl.genderPreference),
              _chip('Male', 'MALE', ctrl.genderPreference),
              _chip('Female', 'FEMALE', ctrl.genderPreference),
            ],
          ),
          const SizedBox(height: 16),
          // Age range
          Row(
            children: [
              const Text('Age range', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Text(
                '${ctrl.ageRangeMin.value} - ${ctrl.ageRangeMax.value}',
                style: const TextStyle(color: Color(0xFFFF6B9D), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFFF6B9D),
              inactiveTrackColor: Colors.white.withOpacity(0.15),
              thumbColor: const Color(0xFFFF6B9D),
              overlayColor: const Color(0x29FF6B9D),
            ),
            child: RangeSlider(
              values: RangeValues(ctrl.ageRangeMin.value.toDouble(), ctrl.ageRangeMax.value.toDouble()),
              min: 18,
              max: 60,
              onChanged: (v) {
                ctrl.ageRangeMin.value = v.start.round();
                ctrl.ageRangeMax.value = v.end.round();
              },
            ),
          ),
          const SizedBox(height: 8),
          // Save preferences toggle
          Row(
            children: [
              const Text('Enable blind date', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Switch(
                value: ctrl.isEnabled.value,
                onChanged: (v) {
                  ctrl.isEnabled.value = v;
                  ctrl.savePreferences();
                },
                activeColor: const Color(0xFFFF6B9D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, Rx<String> selected) {
    final isSelected = selected.value == value;
    return GestureDetector(
      onTap: () {
        selected.value = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D).withOpacity(0.2) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFFF6B9D) : Colors.white.withOpacity(0.15)),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? const Color(0xFFFF6B9D) : Colors.white70, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _searchButton(BlindDateController ctrl) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: ctrl.isSearching.value ? null : () => ctrl.startSearch(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF1493)]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (ctrl.isSearching.value)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              else
                const Icon(Icons.search, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                ctrl.isSearching.value ? 'Searching...' : 'Find Blind Date',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingOrCallView(BlindDateController ctrl) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0033), Color(0xFF0D001A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            // Pulsing avatar placeholder
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFF6B9D).withOpacity(0.3),
                  const Color(0xFFFF6B9D).withOpacity(0.05),
                ]),
              ),
              child: const Center(
                child: Icon(Icons.person_search, size: 50, color: Color(0xFFFF6B9D)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Finding someone special...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              'Hang tight, we\'re looking for your perfect match',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => ctrl.stopSearch(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionView(BlindDateController ctrl) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0033), Color(0xFF0D001A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.person, size: 80, color: Color(0xFFFF6B9D)),
            const SizedBox(height: 16),
            Text(
              ctrl.session.value?['otherUser']?['name'] ?? 'Blind Date',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              ctrl.session.value?['icebreaker'] ?? '',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
