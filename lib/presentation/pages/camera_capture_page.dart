import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});
  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cams = await availableCameras();
    final cam = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );
    _controller = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
    _initFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _take() async {
    if (_controller == null) return;
    await _initFuture;
    final shot = await _controller!.takePicture();
    // Copia al directorio de la app (archivo estable)
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final saved = await File(shot.path).copy(dest.path);
    if (!mounted) return;
    Navigator.of(context).pop(saved.path); // devolvemos la ruta
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: (_controller == null)
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    Center(child: CameraPreview(_controller!)),
                    Positioned(
                      bottom: 32,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          onPressed: _take,
                          child: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}