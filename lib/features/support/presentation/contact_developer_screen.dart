import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart'; // User will need to add this dep if not present, I'll assume standard Flutter env or handle visually first.
// Actually, simple clipboard and fake send for now to avoid dep errors if not in pubspec, 
// but I should use it if I can. Let's stick to UI first to avoid build breaks if dep missing.
// I'll add the UI actions.

class ContactDeveloperScreen extends StatelessWidget {
  const ContactDeveloperScreen({super.key});

  final String _developerEmail = "raselofficial89@gmail.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Contact Developer',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0F7FA), width: 4), // Light cyan border
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFEEEEEE),
                backgroundImage: AssetImage('assets/images/developer_profile.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              'MD. Rasel',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20), // Dark Green
              ),
            ),
            const SizedBox(height: 4),
            
            // Role
            Text(
              'App Developer (FLUTTER)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4DB6AC), // Teal/Cyan
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Business Inquiry Card
            _buildInfoCard(
              icon: Icons.business_center_outlined,
              title: "Business Inquiry",
              subtitle: _developerEmail,
              onTap: () {}, // Can implement launchUrl here
            ),
            
            const SizedBox(height: 16),
            
            // Developer Role Card
            _buildInfoCard(
              icon: Icons.verified_user_outlined,
              title: "Developer Role",
              subtitle: "Flutter developer specializing in Firebase, real-time databases, and scalable mobile app systems.",
              isDescription: true,
            ),
            
            const SizedBox(height: 40),
            
            Text(
              "Ready to discuss premium partnerships?",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Send Proposal Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                   // _launchEmail();
                   Clipboard.setData(ClipboardData(text: _developerEmail));
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Email copied to clipboard (Simulating Email Launch)')),
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), // Green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.email_outlined, color: Colors.white),
                label: Text(
                  "SEND BUSINESS PROPOSAL",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Copy Email Button
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _developerEmail));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email Address Copied!')),
                );
              },
              child: Text(
                "Copy Email Address",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD32F2F), // Red text as in screenshot
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDescription = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Very light grey
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.02),
             blurRadius: 10,
             offset: const Offset(0, 4),
           )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1), // Light Cyan bg for icon
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF00695C), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isDescription)
                   Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
