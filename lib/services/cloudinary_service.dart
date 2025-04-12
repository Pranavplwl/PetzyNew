import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class CloudinaryService {
  static const _cloudinaryUrl = 'https://api.cloudinary.com/v1_1';
  static const _uploadTimeout = Duration(seconds: 30);
  static const _maxRetries = 2;

  final String _cloudName;
  final String _apiKey;
  final String _apiSecret;

  CloudinaryService()
      : _cloudName = dotenv.get('CLOUDINARY_CLOUD_NAME'),
        _apiKey = dotenv.get('CLOUDINARY_API_KEY'),
        _apiSecret = dotenv.get('CLOUDINARY_API_SECRET') {
    assert(_cloudName.isNotEmpty, 'Cloudinary cloud name not set');
    assert(_apiKey.isNotEmpty, 'Cloudinary API key not set');
    assert(_apiSecret.isNotEmpty, 'Cloudinary API secret not set');
  }

  Future<String?> uploadImage(XFile imageFile, {int retryCount = 0}) async {
    try {
      final fileBytes = await imageFile.readAsBytes();
      final fileName = path.basename(imageFile.path);
      final mimeType =
          lookupMimeType(imageFile.path) ?? 'application/octet-stream';
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final params = {
        'folder': 'petzy',
        'timestamp': timestamp,
      };
      final signature = _generateSignature(params);

      final uri = Uri.parse('$_cloudinaryUrl/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['api_key'] = _apiKey
        ..fields['timestamp'] = timestamp
        ..fields['signature'] = signature
        ..fields['folder'] = 'petzy'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ));

      if (kDebugMode) {
        debugPrint(
            'Uploading image to Cloudinary: $fileName (${fileBytes.length} bytes)');
        debugPrint('Using signature: $signature');
        debugPrint('MIME type: $mimeType');
      }

      final response =
          await request.send().timeout(_uploadTimeout, onTimeout: () {
        throw TimeoutException(
            'Cloudinary upload timed out after $_uploadTimeout');
      });

      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'] as String?;
      } else {
        final errorMsg = jsonResponse['error']?['message'] ?? 'Unknown error';
        throw HttpException('Cloudinary upload failed ($errorMsg)');
      }
    } on SocketException catch (e) {
      if (retryCount < _maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
        return uploadImage(imageFile, retryCount: retryCount + 1);
      }
      debugPrint('Network error after $_maxRetries retries: $e');
      rethrow;
    } on TimeoutException catch (e) {
      if (retryCount < _maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
        return uploadImage(imageFile, retryCount: retryCount + 1);
      }
      debugPrint('Timeout after $_maxRetries retries: $e');
      rethrow;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      rethrow;
    }
  }

  String _generateSignature(Map<String, String> params) {
    final sortedParams = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final stringToSign =
        sortedParams.map((entry) => '${entry.key}=${entry.value}').join('&');

    final bytes = utf8.encode('$stringToSign$_apiSecret');
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
