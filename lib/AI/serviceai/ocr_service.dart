import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OCRService {
  static const String _apiKey = 'SUA_CHAVE_GOOGLE_CLOUD';
  static const String _visionUrl = 
    'https://vision.googleapis.com/v1/images:annotate';

  Future<String> extractTextFromImage(File image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('$_visionUrl?key=$_apiKey'),
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'TEXT_DETECTION'}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final text = jsonDecode(response.body)
        ['responses'][0]['textAnnotations'][0]['description'];
      return text;
    } else {
      throw Exception('OCR falhou: ${response.body}');
    }
  }
}