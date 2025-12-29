import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amar_bari/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../data/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final tealColor = const Color(0xFF009688); // Matching the image's teal header

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.settingsTitle, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: tealColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Language Settings Tile matching image
          _buildDetailTile(
            context,
            title: l10n.language,
            subtitle: settingsState.locale.languageCode == 'en' ? 'Current: English' : 'বর্তমান: বাংলা',
            onTap: () => _showLanguagePicker(context, ref, settingsState.locale.languageCode),
          ),
          
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildDetailTile(BuildContext context, {required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListTile(
        title: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String currentLang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, ref, 'বাংলা', 'bn', currentLang == 'bn'),
              _buildLanguageOption(context, ref, 'English', 'en', currentLang == 'en'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String label, String code, bool isSelected) {
    return ListTile(
      title: Text(label, style: GoogleFonts.poppins(fontSize: 18, color: isSelected ? Colors.black : Colors.grey[700])),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF009688)) : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setLocale(code);
        Navigator.pop(context);
      },
      selected: isSelected,
      selectedTileColor: Colors.grey[100],
    );
  }
}
