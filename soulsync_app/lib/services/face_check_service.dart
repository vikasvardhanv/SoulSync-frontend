import 'dart:io';
import 'package:flutter/services.dart';

class FaceCheckResult {
  final bool verified;
  final double similarity;
  final double liveness;
  final String reason;

  const FaceCheckResult({
    required this.verified,
    required this.similarity,
    required this.liveness,
    required this.reason,
  });

  factory FaceCheckResult.fromMap(Map<dynamic, dynamic> data) {
    return FaceCheckResult(
      verified: data['verified'] == true,
      similarity: (data['similarity'] as num?)?.toDouble() ?? 0.0,
      liveness: (data['liveness'] as num?)?.toDouble() ?? 0.0,
      reason: (data['reason'] as String?) ?? 'Unknown verification result',
    );
  }
}

class FaceCheckService {
  static const MethodChannel _channel = MethodChannel('soulsync/face_check');
  static const String _activationKey = String.fromEnvironment(
    'FACEPLUGIN_IOS_LICENSE',
    defaultValue: '',
  );

  static const double defaultSimilarityThreshold = 0.82;
  static const double defaultLivenessThreshold = 0.70;

  Future<bool> initializeSdk() async {
    if (!Platform.isIOS) return false;
    if (_activationKey.isEmpty) {
      throw const FaceCheckException(
        'Missing FACEPLUGIN_IOS_LICENSE. Add it with --dart-define.',
      );
    }

    try {
      await _channel.invokeMethod('initializeSdk', {
        'activationKey': _activationKey,
      });
      return true;
    } on PlatformException catch (e) {
      throw FaceCheckException(e.message ?? 'Failed to initialize face SDK');
    }
  }

  Future<FaceCheckResult> performFaceCheck({
    required String referenceImagePath,
    required String selfieImagePath,
    double similarityThreshold = defaultSimilarityThreshold,
    double livenessThreshold = defaultLivenessThreshold,
  }) async {
    if (!Platform.isIOS) {
      throw const FaceCheckException(
        'Face check is currently enabled for iOS only.',
      );
    }

    if (_activationKey.isEmpty) {
      throw const FaceCheckException(
        'Missing FACEPLUGIN_IOS_LICENSE. Add it with --dart-define.',
      );
    }

    try {
      final result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('performFaceCheck', {
            'activationKey': _activationKey,
            'referenceImagePath': referenceImagePath,
            'selfieImagePath': selfieImagePath,
            'similarityThreshold': similarityThreshold,
            'livenessThreshold': livenessThreshold,
          });
      if (result == null) {
        throw const FaceCheckException('No face-check result returned.');
      }
      return FaceCheckResult.fromMap(result);
    } on PlatformException catch (e) {
      throw FaceCheckException(e.message ?? 'Face check failed.');
    }
  }
}

class FaceCheckException implements Exception {
  final String message;
  const FaceCheckException(this.message);

  @override
  String toString() => message;
}
