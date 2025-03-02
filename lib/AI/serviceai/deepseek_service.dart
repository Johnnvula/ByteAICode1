import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekService {
  static const String _apiKey = 'SUA_CHAVE_API_DEEPSEEK';
  static const String _apiUrl = 'https://api.deepseek.com/v1/completions';

  Future<String> hybridGeneration(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'deepseek-coder',
        'prompt': "Gere código Dart/Flutter para: $prompt",
        'max_tokens': 1500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['text'].trim();
    } else {
      throw Exception('Falhas ao gerar código: ${response.body}');
    }
  }
}