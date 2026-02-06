import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/gemstone_scan_result.dart';

class GemstoneScanService {
  /// Identify gemstone from image file
  Future<GemstoneScanResult> identifyGemstone(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send to API
      final url = Uri.parse('${ApiConfig.chatbotUrl}/api/identify-gemstone');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Image}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return GemstoneScanResult.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        // Validation error
        final error = jsonDecode(response.body);
        return GemstoneScanResult(
          success: false,
          gemstoneName: 'Unknown',
          confidence: 'Low',
          error: error['detail'] ?? 'Invalid image',
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      return GemstoneScanResult(
        success: false,
        gemstoneName: 'Unknown',
        confidence: 'Low',
        error: 'Failed to identify gemstone: ${e.toString()}',
      );
    }
  }
}
