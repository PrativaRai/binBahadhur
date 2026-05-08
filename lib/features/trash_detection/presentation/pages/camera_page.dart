import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:binbahadhur/features/trash_detection/presentation/pages/photo_preview_page.dart';
import 'package:binbahadhur/core/widgets/custom_app_bar.dart';

class CameraPage extends StatefulWidget {
  final String mode;
  final String? scheduleId;
  final String? reportId;
  const CameraPage({
    super.key,
    required this.mode,
    this.scheduleId,
    this.reportId,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    controller = CameraController(firstCamera, ResolutionPreset.medium);

    await controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !(controller?.value.isInitialized ?? false)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "Camera", showBackButton: true),

      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.previewSize!.height,
                  height: controller!.value.previewSize!.width,
                  child: CameraPreview(controller!),
                ),
              ),
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    final picture = await controller!.takePicture();

                    if (!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoPreviewPage(
                          imageFile: File(picture.path),
                          mode: widget.mode,
                          scheduleId: widget.scheduleId,
                          reportId: widget.reportId,
                        ),
                      ),
                    );
                  },

                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.green, width: 4),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
