import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../theme.dart';

const kinshasa = LatLng(-4.325, 15.322);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng _center = kinshasa;
  bool _locating = false;

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw StateError('Activez le service de localisation.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Autorisez KinNav à accéder à votre position.');
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _center = LatLng(position.latitude, position.longitude));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: _center, initialZoom: 12),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'org.kinnav.mobile',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: _center,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
                ]),
              ],
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => context.push('/search'),
                        borderRadius: BorderRadius.circular(14),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(children: [
                            Icon(Icons.search),
                            SizedBox(width: 12),
                            Text('Où allez-vous ?', style: TextStyle(fontSize: 16)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TrafficLegend(),
                    ),
                  ),
                  const Spacer(),
                  const AnonymousBanner(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FloatingActionButton(
                          heroTag: 'locate',
                          onPressed: _locating ? null : _locate,
                          child: _locating
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.my_location),
                        ),
                        FloatingActionButton.extended(
                          heroTag: 'navigate',
                          onPressed: () => context.push('/search'),
                          icon: const Icon(Icons.navigation),
                          label: const Text('Itinéraire'),
                        ),
                      ],
                    ),
                  ),
                  const BottomNav(selectedIndex: 0),
                ],
              ),
            ),
          ],
        ),
      );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _destination = TextEditingController();

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Rechercher un trajet')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Départ',
                prefixIcon: Icon(Icons.my_location),
                hintText: 'Ma position',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destination,
              decoration: const InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'Adresse à Kinshasa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_destination.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saisissez une destination.')),
                    );
                    return;
                  }
                  context.push('/routes');
                },
                child: const Text('Rechercher un itinéraire'),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 28, bottom: 8),
                child: Text('Trajets récents', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.history),
              title: Text('Aucun trajet récent'),
              subtitle: Text('Vos derniers trajets apparaîtront ici.'),
            ),
          ]),
        ),
      );
}

class RouteResultsScreen extends StatelessWidget {
  const RouteResultsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Itinéraires')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RouteCard(
              recommended: true,
              duration: '— min',
              distance: '— km',
              subtitle: 'Connectez le service de routage avec un graphe OSM.',
              onTap: () => context.push('/navigation'),
            ),
            RouteCard(
              recommended: false,
              duration: '— min',
              distance: '— km',
              subtitle: 'Le trafic sera disponible après configuration des données.',
              onTap: () => context.push('/navigation'),
            ),
          ],
        ),
      );
}

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          FlutterMap(
            options: const MapOptions(initialCenter: kinshasa, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'org.kinnav.mobile',
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Préparez votre itinéraire', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('La navigation guidée sera disponible avec le routage connecté.'),
                    const SizedBox(height: 12),
                    Row(children: [
                      OutlinedButton.icon(
                        onPressed: () => _showReportDialog(context),
                        icon: const Icon(Icons.warning_amber),
                        label: const Text('Signaler'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Arrêter'),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      );
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Alertes')),
        body: Column(children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Wrap(spacing: 8, children: [
              Chip(label: Text('Tout')),
              Chip(label: Text('Autour')),
              Chip(label: Text('Mon trajet')),
            ]),
          ),
          const Expanded(
            child: Center(
              child: Text('Aucun signalement pour le moment.'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () => _showReportDialog(context),
              icon: const Icon(Icons.add_alert),
              label: const Text('Nouveau signalement'),
            ),
          ),
          const BottomNav(selectedIndex: 1),
        ]),
      );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: Column(children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text('Conducteur anonyme'),
            subtitle: Text('Mode anonyme'),
          ),
          const ListTile(
            leading: Icon(Icons.route_outlined),
            title: Text('Trajets restants aujourd’hui'),
            trailing: Text('3'),
          ),
          const ListTile(
            leading: Icon(Icons.workspace_premium_outlined),
            title: Text('KinNav Premium'),
            subtitle: Text('Offres et fonctionnalités à venir'),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Langue'),
            trailing: Text('Français'),
          ),
          const Spacer(),
          const BottomNav(selectedIndex: 2),
        ]),
      );
}

class RouteCard extends StatelessWidget {
  const RouteCard({
    required this.recommended,
    required this.duration,
    required this.distance,
    required this.subtitle,
    required this.onTap,
    super.key,
  });
  final bool recommended;
  final String duration;
  final String distance;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: recommended ? AppColors.trafficFree : AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (recommended)
                const Chip(
                  label: Text('Recommandé'),
                  backgroundColor: Color(0x2234C759),
                ),
              Text(duration, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
              Text('$distance · Trafic inconnu'),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: AppColors.secondary)),
            ]),
          ),
        ),
      );
}

class AnonymousBanner extends StatelessWidget {
  const AnonymousBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Text('Mode anonyme — 3 trajets restants'),
      );
}

class TrafficLegend extends StatelessWidget {
  const TrafficLegend({super.key});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _LegendItem(color: AppColors.trafficFree, text: 'Fluide'),
            _LegendItem(color: AppColors.trafficSlow, text: 'Ralentissement'),
            _LegendItem(color: AppColors.trafficBlocked, text: 'Bloqué'),
          ]),
        ),
      );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ]);
}

class BottomNav extends StatelessWidget {
  const BottomNav({required this.selectedIndex, super.key});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final paths = ['/', '/alerts', '/profile'];
          context.go(paths[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Carte'),
          NavigationDestination(icon: Icon(Icons.warning_amber_outlined), label: 'Alertes'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      );
}

Future<void> _showReportDialog(BuildContext context) async {
  final description = TextEditingController();
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nouveau signalement'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          items: const [
            DropdownMenuItem(value: 'accident', child: Text('Accident')),
            DropdownMenuItem(value: 'works', child: Text('Travaux')),
            DropdownMenuItem(value: 'jam', child: Text('Bouchon')),
            DropdownMenuItem(value: 'flood', child: Text('Inondation')),
          ],
          onChanged: (_) {},
          decoration: const InputDecoration(labelText: 'Type'),
        ),
        TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Envoyer')),
      ],
    ),
  );
  description.dispose();
  if (accepted == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connectez le service trafic pour envoyer le signalement.')),
    );
  }
}
