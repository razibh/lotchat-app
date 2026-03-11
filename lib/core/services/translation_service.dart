import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _currentLocale = 'en-US';

  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'bn': 'Bengali',
  };

  Future<void> initialize() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  // ==================== SPEECH TO TEXT ====================
  Future<bool> initSpeech() async {
    bool available = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    return available;
  }

  Future<String?> listen({
    required Function(String text) onResult,
    required Function(String error) onError,
    String? locale,
  }) async {
    if (!_isListening) {
      bool available = await initSpeech();
      if (available) {
        _isListening = true;
        await _speech.listen(
          onResult: (result) {
            onResult(result.recognizedWords);
          },
          listenFor: Duration(seconds: 30),
          localeId: locale ?? _currentLocale,
        );
      } else {
        onError('Speech recognition not available');
      }
    } else {
      await stopListening();
    }
    return null;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  // ==================== TEXT TO SPEECH ====================
  Future<void> speak(String text, {String? language}) async {
    if (language != null) {
      await _tts.setLanguage(language);
    }
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // ==================== TRANSLATION API ====================
  Future<String?> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    try {
      // Using Google Translate API (you'll need API key)
      final apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
      final url = 'https://translation.googleapis.com/language/translate/v2';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
        },
        body: jsonEncode({
          'q': text,
          'source': fromLanguage,
          'target': toLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      }
      
      return null;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }

  // ==================== REAL-TIME TRANSLATION ====================
  Stream<String> realTimeTranslation({
    required Stream<String> inputStream,
    required String fromLanguage,
    required String toLanguage,
  }) async* {
    await for (var text in inputStream) {
      if (text.isNotEmpty) {
        final translated = await translateText(
          text: text,
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
        );
        if (translated != null) {
          yield translated;
        }
      }
    }
  }

  // ==================== VOICE TRANSLATION ====================
  Future<String?> voiceToVoice({
    required String fromLanguage,
    required String toLanguage,
  }) async {
    // Listen to speech
    String? recognizedText;
    await listen(
      onResult: (text) {
        recognizedText = text;
      },
      onError: (error) {
        print('Error listening: $error');
      },
      locale: fromLanguage,
    );

    if (recognizedText == null) return null;

    // Translate text
    final translatedText = await translateText(
      text: recognizedText!,
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
    );

    if (translatedText != null) {
      // Speak translated text
      await speak(translatedText, language: toLanguage);
      return translatedText;
    }

    return null;
  }

  // ==================== LANGUAGE DETECTION ====================
  Future<String?> detectLanguage(String text) async {
    try {
      final apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
      final url = 'https://translation.googleapis.com/language/translate/v2/detect';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
        },
        body: jsonEncode({
          'q': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['detections'][0][0]['language'];
      }
      
      return null;
    } catch (e) {
      print('Language detection error: $e');
      return null;
    }
  }

  // ==================== GET AVAILABLE VOICES ====================
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    final voices = await _tts.getVoices;
    return voices;
  }

  // ==================== SET VOICE ====================
  Future<void> setVoice(Map<String, dynamic> voice) async {
    await _tts.setVoice(voice);
  }

  // ==================== DISPOSE ====================
  void dispose() {
    _speech.stop();
    _tts.stop();
  }
}