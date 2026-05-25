import 'package:classemortaremake/core/api/http_client.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
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
      // First, always go back to the root (Home)
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      // If a specific route is requested and it's not home, push it
      if (routeName != null && routeName != '/home') {
        Navigator.of(context).pushNamed(routeName);
      }
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icon/icona.png',
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.school, size: 40),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "ClasseMorta Plus",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: "Home",
                    onTap: () => navigateTo('/home'),
                  ),
                  _DrawerItem(
                    icon: Icons.medical_information_rounded,
                    label: "Materie",
                    onTap: () => navigateTo('/subjects'),
                  ),
                  _DrawerItem(
                    icon: Icons.edit_calendar_outlined,
                    label: "Compiti",
                    onTap: () => navigateTo('/agenda'),
                  ),
                  _DrawerItem(
                    icon: Icons.event_busy,
                    label: "Assenze",
                    onTap: () => navigateTo('/absences'),
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_month,
                    label: "Notizie",
                    onTap: () => navigateTo('/noticeboard'),
                  ),
                  _DrawerItem(
                    icon: Icons.edit_note_outlined,
                    label: "Note",
                    onTap: () => navigateTo('/notes'),
                  ),
                  _DrawerItem(
                    icon: Icons.sticky_note_2_outlined,
                    label: "Didattica",
                    onTap: () => navigateTo('/didactic'),
                  ),
                  _DrawerItem(
                    icon: Icons.watch_later,
                    label: "Orari",
                    onTap: () => navigateTo('/schedule'),
                  ),
                  _DrawerItem(
                    icon: Icons.book,
                    label: "Curriculum",
                    onTap: () => navigateTo('/curriculum'),
                  ),
                  if (isParent)
                    _DrawerItem(
                      icon: Icons.add,
                      label: "Giustifiche",
                      onTap: () => navigateTo('/justifications'),
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
