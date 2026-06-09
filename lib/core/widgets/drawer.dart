import 'package:classemortaremake/core/api/http_client.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class AppDrawerButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const AppDrawerButton({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: context.theme.iconButtonTheme.style,
      onPressed: () {
        scaffoldKey.currentState!.openDrawer();
      },
      icon: const Icon(Icons.menu),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final client = HttpClient();
    final bool isParent = client.studentCode?.startsWith('G') ?? false;

    void navigateTo(String? routeName) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      if (routeName != null && routeName != '/home') {
        Navigator.of(context).pushNamed(routeName);
      }
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.65,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
              ),
              currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/icon/icona.png',
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.school, size: 40),
                ),
              ),
              accountName: Text(
                "ClasseMorta Plus",
                style: TextStyle(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                "${client.firstName ?? ''} ${client.lastName ?? ''}",
                style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --- PRINCIPALI ---
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: "Home",
                    onTap: () => navigateTo('/home'),
                  ),
                  _DrawerItem(
                    icon: Icons.medical_information_rounded,
                    label: "Medie materie",
                    onTap: () => navigateTo('/subjects'),
                  ),
                  _DrawerItem(
                    icon: Icons.edit_calendar_outlined,
                    label: "Compiti",
                    onTap: () => navigateTo('/agenda'),
                  ),
                  
                  const Divider(indent: 16, endIndent: 16),
                  
                  // --- DIDATTICA E LEZIONI ---
                  _DrawerItem(
                    icon: Icons.list_alt_rounded,
                    label: "Lezioni",
                    onTap: () => navigateTo('/lessons'),
                  ),
                  _DrawerItem(
                    icon: Icons.watch_later,
                    label: "Orario",
                    onTap: () => navigateTo('/schedule'),
                  ),
                  _DrawerItem(
                    icon: Icons.sticky_note_2_outlined,
                    label: "Didattica",
                    onTap: () => navigateTo('/didactic'),
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: "Docenti",
                    onTap: () => navigateTo('/teachers'),
                  ),

                  const Divider(indent: 16, endIndent: 16),

                  // --- ASSENZE E NOTE ---
                  _DrawerItem(
                    icon: Icons.event_busy,
                    label: "Assenze",
                    onTap: () => navigateTo('/absences'),
                  ),
                  _DrawerItem(
                    icon: Icons.edit_note_outlined,
                    label: "Note/Annotazioni",
                    onTap: () => navigateTo('/notes'),
                  ),
                  if (isParent)
                    _DrawerItem(
                      icon: Icons.add,
                      label: "Giustifiche",
                      onTap: () => navigateTo('/justifications'),
                    ),

                  const Divider(indent: 16, endIndent: 16),

                  // --- COMUNICAZIONI E ALTRO ---
                  _DrawerItem(
                    icon: Icons.calendar_month,
                    label: "Bacheca",
                    onTap: () => navigateTo('/noticeboard'),
                  ),
                  _DrawerItem(
                    icon: Icons.mark_email_read,
                    label: "Pagelle",
                    onTap: () => navigateTo('/report_cards'),
                  ),
                  _DrawerItem(
                    icon: Icons.book,
                    label: "Curriculum PCTO",
                    onTap: () => navigateTo('/curriculum'),
                  ),
                  _DrawerItem(
                    icon: Icons.games_outlined,
                    label: "Vacanze",
                    onTap: () => navigateTo('/holidays'),
                  ),
                  _DrawerItem(
                    icon: Icons.emoji_events,
                    label: "Trofei",
                    onTap: () => navigateTo('/achievements'),
                  ),

                  const Divider(),

                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: "Impostazioni",
                    onTap: () => navigateTo('/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colorScheme.secondary),
      title: Text(label, style: context.textTheme.bodyMedium),
      onTap: () {
        Navigator.pop(context); // Close the drawer first
        onTap();
      },
    );
  }
}
