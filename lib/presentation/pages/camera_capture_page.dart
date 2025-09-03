// Import Dart library to handle files
import 'dart:io';
// Import the Flutter camera package
import 'package:camera/camera.dart';
// Import Flutter Material (UI widgets)
import 'package:flutter/material.dart';
// Allows access to device directories
import 'package:path_provider/path_provider.dart';

// Stateful widget representing the camera capture screen
class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  // Creates the state associated with this widget
  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

// State of the CameraCapturePage widget
class _CameraCapturePageState extends State<CameraCapturePage> {
  // Camera controller (null if not initialized yet)
  CameraController? _controller;
  // Future indicating when the camera is initialized
  Future<void>? _initFuture;

  // Called when the widget is first created
  @override
  void initState() {
    super.initState();
    _init(); // Calls the method that initializes the camera
  }

  // Initializes the camera
  Future<void> _init() async {
    // Get the list of available cameras
    final cams = await availableCameras();
    // Select the back camera if available, otherwise the first one
    final cam = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );
    // Create the camera controller with medium resolution and audio disabled
    _controller = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
    // Initialize the controller and store the Future
    _initFuture = _controller!.initialize();
    // Update the UI to reflect that the camera is initialized
    setState(() {});
  }

  // Called when the widget is removed from the widget tree
  @override
  void dispose() {
    // Dispose of the camera controller to free resources
    _controller?.dispose();
    super.dispose();
  }

  // Method to take a photo
  Future<void> _take() async {
    // If the controller is not ready, do nothing
    if (_controller == null) return;
    // Wait for the camera to be fully initialized
    await _initFuture;
    // Take the picture and save it temporarily
    final shot = await _controller!.takePicture();
    // Get the app's documents directory
    final dir = await getApplicationDocumentsDirectory();
    // Define the final path using a timestamp
    final dest = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    // Copy the photo to the final location
    final saved = await File(shot.path).copy(dest.path);
    // Prevent executing if the widget is no longer mounted
    if (!mounted) return;
    // Close the camera screen and return the photo path
    Navigator.of(context).pop(saved.path);
  }

  // Builds the UI of the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background for camera preview
      body: (_controller == null) // If camera not ready
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : FutureBuilder(
              future: _initFuture, // Wait for camera initialization
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  // While initializing, show a spinner
                  return const Center(child: CircularProgressIndicator());
                }
                // Camera is ready: show preview and buttons
                return Stack(
                  children: [
                    Center(child: CameraPreview(_controller!)), // Camera preview
                    Positioned(
                      bottom: 32,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          onPressed: _take, // Button to take photo
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
                        onPressed: () => Navigator.of(context).pop(), // Button to close camera
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
