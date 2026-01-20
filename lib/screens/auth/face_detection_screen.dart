import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:todo_app/utils/colors.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isFaceDetected = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Find front camera, fallback to first camera if not found
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startFaceDetection();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing camera: $e';
      });
    }
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: false,
      enableContours: false,
      enableTracking: false,
      minFaceSize: 0.3, // Increased from 0.1 to make detection less sensitive
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _startFaceDetection() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;
      _detectFaces(image);
    });
  }

  Future<void> _detectFaces(CameraImage image) async {
    if (_faceDetector == null) {
      _isDetecting = false;
      return;
    }

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);

      if (mounted) {
        // Only set face detected if there's exactly one face and it's well-positioned
        bool faceDetected = false;
        if (faces.length == 1) {
          final face = faces.first;
          // Check if face is reasonably centered and has good size
          final faceRect = face.boundingBox;
          final imageSize = inputImage.metadata?.size;

          if (imageSize != null) {
            // Face should be in center 70% of the image (matching oval area)
            final centerX = imageSize.width / 2;
            final centerY = imageSize.height / 2;
            final faceCenterX = faceRect.center.dx;
            final faceCenterY = faceRect.center.dy;

            // Check if face is within the oval area (center 70% width, 50% height)
            final ovalWidth = imageSize.width * 0.7;
            final ovalHeight = imageSize.height * 0.5;

            final dx = (faceCenterX - centerX).abs();
            final dy = (faceCenterY - centerY).abs();

            // Face should be within oval bounds and have reasonable size
            if (dx < ovalWidth / 2 &&
                dy < ovalHeight / 2 &&
                faceRect.width > imageSize.width * 0.15 &&
                faceRect.height > imageSize.height * 0.15) {
              faceDetected = true;
            }
          }
        }

        setState(() {
          _isFaceDetected = faceDetected;
        });
      }
    } catch (e) {
      // Handle error silently
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final allBytes = <int>[];
      for (final Plane plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }
      final bytes = Uint8List.fromList(allBytes);

      final imageRotation = InputImageRotation.rotation0deg;
      final format = InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } catch (e) {
      return null;
    }
  }

  Future<void> _captureImage() async {
    if (!_isFaceDetected || _cameraController == null) return;

    try {
      final image = await _cameraController!.takePicture();

      if (mounted) {
        // Stop face detection while showing dialog
        await _cameraController!.stopImageStream();

        // Show confirmation dialog with captured image
        final shouldProceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(24.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Captured image preview
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.contain,
                        height: 300.h,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'Confirm Photo',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: kWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Message
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'Do you want to proceed with this image?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: kWhite.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          // Retake button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                side: BorderSide(color: kWhite, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Retake',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: kWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Proceed button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Proceed',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: kWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        );

        // Resume face detection if user chose to retake
        if (shouldProceed == false && mounted) {
          _startFaceDetection();
          return;
        }

        // If user chose to proceed, return the image path
        if (shouldProceed == true && mounted) {
          Navigator.pop(context, image.path);
        }
      }
    } catch (e) {
      // Resume face detection on error
      if (mounted) {
        _startFaceDetection();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kWhite, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Face Detection',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: kWhite,
          ),
        ),
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 16.sp, color: kWhite),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : _isInitialized && _cameraController != null
          ? Stack(
              children: [
                // Camera Preview
                Positioned.fill(child: CameraPreview(_cameraController!)),
                // Overlay with oval shape
                Positioned.fill(
                  child: CustomPaint(
                    painter: FaceDetectionOverlay(
                      isFaceDetected: _isFaceDetected,
                    ),
                  ),
                ),
                // Instructions
                Positioned(
                  top: 40.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _isFaceDetected
                            ? 'Face Detected ✓'
                            : 'Position your face in the oval',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: _isFaceDetected ? Colors.green : kWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                // Capture Button
                Positioned(
                  bottom: 40.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isFaceDetected ? _captureImage : null,
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isFaceDetected
                              ? Colors.green
                              : Colors.grey.withOpacity(0.5),
                          border: Border.all(color: kWhite, width: 4),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: kWhite,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator(color: kPrimaryColor)),
    );
  }
}

class FaceDetectionOverlay extends CustomPainter {
  final bool isFaceDetected;

  FaceDetectionOverlay({required this.isFaceDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFaceDetected ? Colors.green : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final ovalWidth = size.width * 0.7;
    final ovalHeight = size.height * 0.5;

    // Draw oval shape
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: ovalWidth,
      height: ovalHeight,
    );

    canvas.drawOval(rect, paint);

    // Draw semi-transparent overlay outside oval
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw top overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, centerY - ovalHeight / 2),
      overlayPaint,
    );

    // Draw bottom overlay
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        centerY + ovalHeight / 2,
        size.width,
        size.height - (centerY + ovalHeight / 2),
      ),
      overlayPaint,
    );

    // Draw left overlay
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        centerY - ovalHeight / 2,
        centerX - ovalWidth / 2,
        ovalHeight,
      ),
      overlayPaint,
    );

    // Draw right overlay
    canvas.drawRect(
      Rect.fromLTWH(
        centerX + ovalWidth / 2,
        centerY - ovalHeight / 2,
        centerX - ovalWidth / 2,
        ovalHeight,
      ),
      overlayPaint,
    );
  }

  @override
  bool shouldRepaint(FaceDetectionOverlay oldDelegate) {
    return oldDelegate.isFaceDetected != isFaceDetected;
  }
}
