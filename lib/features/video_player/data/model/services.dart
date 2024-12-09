import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiUrl =
      "https://dev-the-dark-lord.pantheonsite.io/wp-admin/js/Apis/Gemini.php?message=";
  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl + Uri.encodeComponent(message)),
      );
      print('${response.body}response in fun ');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('${data}message to gemini in fun ');
        return data; // Adjust based on the actual response structure
      } else {
        throw Exception('Failed to get response from Gemini AI');
      }
    } catch (e) {
      print('error in send$e');
      return e.toString();
    }
  }

  // final String _apiKey =
  //     'AIzaSyBAsNwOsjiGIc9zZoaJQLtGJzc20861YEk'; // Replace with your actual API key

  static Future<String> sendPrompt(String contents) async {
    final String apiKey = "AIzaSyCixWIj8CMcxM6K6iPAv4jTufdW2sqkmd8";

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-8b',
        apiKey: apiKey,
      );

      final response = await model.generateContent([Content.text(contents) ]);
      String res = response.text!;
      print('${res}this is translation');
      return res;
    } catch (e) {
      print(e.toString() + 'this is the erroe in prompt');
      return e.toString();
    }
  }
}
