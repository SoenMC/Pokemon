import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'camera_capture_page.dart';

class SightingsPage extends StatefulWidget {
  const SightingsPage({super.key});
  @override
  State<SightingsPage> createState() => _SightingsPageState();
}

class _SightingsPageState extends State<SightingsPage> {
  Box? _box;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox('sightings');
    if (mounted) setState(() {});
  }

  Future<bool> _ensureCameraPermission() async {
    var cam = await Permission.camera.status;
    if (!cam.isGranted) cam = await Permission.camera.request();
    return cam.isGranted;
  }

  Future<Position?> _getPositionOrNull() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) return null;

    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (_) {
      try {
        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> _addSighting() async {
    // 1) cámara embebida (no salimos de la app)
    final okCam = await _ensureCameraPermission();
    if (!okCam) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sin permiso de cámara')),
        );
      }
      return;
    }

    final photoPath = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CameraCapturePage()),
    );
    if (photoPath == null) return; // cancelado

    // 2) ubicación opcional
    final pos = await _getPositionOrNull();

    // 3) guardar en Hive
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox('sightings');
    }
    final entry = {
      'photoPath': photoPath,
      'lat': pos?.latitude,
      'lng': pos?.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _box!.add(entry);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pos == null
              ? 'Avistamiento guardado (sin ubicación)'
              : 'Avistamiento guardado (${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)})',
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _deleteAt(int index) async {
    await _box?.deleteAt(index);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_box == null || !(_box?.isOpen ?? false)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sightings'),
        actions: [
          // Botón de prueba opcional: crear item sin cámara
          // IconButton(
          //   icon: const Icon(Icons.bug_report),
          //   onPressed: () async {
          //     await _box!.add({
          //       'photoPath': '',
          //       'lat': null,
          //       'lng': null,
          //       'timestamp': DateTime.now().toIso8601String(),
          //     });
          //     if (mounted) setState(() {});
          //   },
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSighting,
        child: const Icon(Icons.add_a_photo),
      ),
      body: ValueListenableBuilder(
        valueListenable: _box!.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No sightings yet'));
          }
          return ListView.separated(
            itemCount: box.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final raw = box.getAt(i);
              final item = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
              final path = (item['photoPath'] ?? '') as String;
              final file = File(path);
              final lat = item['lat'] as double?;
              final lng = item['lng'] as double?;
              final coord = (lat != null && lng != null)
                  ? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}'
                  : 'Sin ubicación';
              final when = DateTime.tryParse((item['timestamp'] ?? '') as String)
                      ?.toLocal()
                      .toString() ??
                  '';

              return ListTile(
                leading: (path.isNotEmpty && file.existsSync())
                    ? Image.file(file, width: 56, height: 56, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 40),
                title: Text(coord),
                subtitle: Text(when),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAt(i),
                  tooltip: 'Delete',
                ),
              );
            },
          );
        },
      ),
    );
  }
}