import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String _cloudName = 'dpfhr81ee';
  static const String _uploadPreset = 'sugenix';
  static const String _baseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  // Upload single image
  static Future<String> uploadImage(XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception(
          'Failed to upload image: ${jsonResponse['error']['message']}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload multiple images
  static Future<List<String>> uploadImages(List<XFile> imageFiles) async {
    List<String> uploadedUrls = [];

    for (XFile imageFile in imageFiles) {
      try {
        String url = await uploadImage(imageFile);
        uploadedUrls.add(url);
      } catch (e) {
        throw Exception('Failed to upload image ${imageFile.name}: $e');
      }
    }

    return uploadedUrls;
  }

  // Get optimized image URL
  static String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? quality = 'auto',
    String? format = 'auto',
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    String optimizedUrl = originalUrl;

    // Add transformations
    List<String> transformations = [];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (quality != null) transformations.add('q_$quality');
    if (format != null) transformations.add('f_$format');

    if (transformations.isNotEmpty) {
      String transformString = transformations.join(',');
      optimizedUrl = originalUrl.replaceAll(
        '/upload/',
        '/upload/$transformString/',
      );
    }

    return optimizedUrl;
  }

  // Delete image from Cloudinary
  static Future<void> deleteImage(String publicId) async {
    try {
      var url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy';
      var response = await http.post(
        Uri.parse(url),
        body: {'public_id': publicId, 'upload_preset': _uploadPreset},
      );

      if (response.statusCode != 200) {
        var responseData = json.decode(response.body);
        throw Exception(
          'Failed to delete image: ${responseData['error']['message']}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Extract public ID from Cloudinary URL
  static String? extractPublicId(String url) {
    try {
      if (!url.contains('cloudinary.com')) return null;

      RegExp regex = RegExp(r'/v\d+/([^/]+)\.');
      Match? match = regex.firstMatch(url);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }

  // Get image info
  static Future<Map<String, dynamic>> getImageInfo(String publicId) async {
    try {
      var url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/$publicId';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get image info');
      }
    } catch (e) {
      throw Exception('Failed to get image info: $e');
    }
  }
}
