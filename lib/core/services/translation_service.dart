import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TranslationService {
  factory TranslationService() => _instance;
  TranslationService._internal();
  static final TranslationService _instance = TranslationService._internal();

  late SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _isInitialized = false;
  final String _currentLocale = 'en-US';

  // Supported languages
  static const Map<String, String> supportedLanguages = <String, String>{
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

  // Initialize method
  Future<void> initialize() async {
    try {
      debugPrint('📝 Initializing TranslationService...');

      _speech = SpeechToText();
      _tts = FlutterTts();

      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1);

      _isInitialized = true;
      debugPrint('✅ TranslationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing TranslationService: $e');
    }
  }

  // ==================== SPEECH TO TEXT ====================
  Future<bool> initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (SpeechRecognitionError error) => debugPrint('Speech error: $error'),
        onStatus: (String status) => debugPrint('Speech status: $status'),
      );
      return available;
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      return false;
    }
  }

  Future<String?> listen({
    required Function(String text) onResult,
    required Function(String error) onError,
    String? locale,
  }) async {
    if (!_isListening) {
      var available = await initSpeech();
      if (available) {
        _isListening = true;
        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            onResult(result.recognizedWords);
          },
          listenFor: const Duration(seconds: 30),
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
    try {
      if (language != null) {
        await _tts.setLanguage(language);
      }
      await _tts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    }
  }

  // ==================== TRANSLATION API ====================
  Future<String?> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    try {
      const String apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
      const String url = 'https://translation.googleapis.com/language/translate/v2';

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'q': text,
          'source': fromLanguage,
          'target': toLanguage,
          'format': 'text',
          'key': apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      }

      return null;
    } catch (e) {
      debugPrint('Translation error: $e');
      return null;
    }
  }

  // ==================== REAL-TIME TRANSLATION ====================
  Stream<String> realTimeTranslation({
    required Stream<String> inputStream,
    required String fromLanguage,
    required String toLanguage,
  }) async* {
    await for (final String text in inputStream) {
      if (text.isNotEmpty) {
        final String? translated = await translateText(
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
    try {
      String? recognizedText;
      await listen(
        onResult: (String text) {
          recognizedText = text;
        },
        onError: (String error) {
          debugPrint('Error listening: $error');
        },
        locale: fromLanguage,
      );

      if (recognizedText == null) return null;

      final String? translatedText = await translateText(
        text: recognizedText!,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
      );

      if (translatedText != null) {
        await speak(translatedText, language: toLanguage);
        return translatedText;
      }

      return null;
    } catch (e) {
      debugPrint('Voice translation error: $e');
      return null;
    }
  }

  // ==================== LANGUAGE DETECTION ====================
  Future<String?> detectLanguage(String text) async {
    try {
      const String apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
      const String url = 'https://translation.googleapis.com/language/translate/v2/detect';

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'q': text,
          'key': apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['detections'][0][0]['language'];
      }

      return null;
    } catch (e) {
      debugPrint('Language detection error: $e');
      return null;
    }
  }

// ==================== VOICE METHODS ====================
  Future<List> getVoices() async {
    try {
      return await _tts.getVoices ?? <dynamic>[];
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return <dynamic>[];
    }
  }

// Skip setVoice if not needed, use language instead
  Future<void> setLanguage(String language) async {
    try {
      await _tts.setLanguage(language);
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  // Dispose method
  Future<void> dispose() async {
    debugPrint('🗑️ Disposing TranslationService...');

    try {
      if (_isListening) {
        await stopListening();
      }

      await stopSpeaking();

      _isInitialized = false;

      debugPrint('✅ TranslationService disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing TranslationService: $e');
    }
  }

  bool get isInitialized => _isInitialized;
}