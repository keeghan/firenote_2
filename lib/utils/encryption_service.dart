import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EncryptionService {
  /// Generates a deterministic encryption key from the user's UID
  /// This ensures the same user always gets the same key across sessions
  static Uint8List _deriveKey(String userId) {
    // Use PBKDF2-like approach with SHA-256
    final bytes = utf8.encode(userId);
    var hash = sha256.convert(bytes);

    // Multiple iterations for stronger key derivation
    for (int i = 0; i < 1000; i++) {
      hash = sha256.convert(hash.bytes);
    }

    return Uint8List.fromList(hash.bytes);
  }

  /// Simple XOR-based encryption (for demonstration - can be replaced with AES)
  /// In production, consider using the encrypt package for proper AES encryption
  static String _xorEncrypt(String plaintext, Uint8List key) {
    final plaintextBytes = utf8.encode(plaintext);
    final encrypted = Uint8List(plaintextBytes.length);

    for (int i = 0; i < plaintextBytes.length; i++) {
      encrypted[i] = plaintextBytes[i] ^ key[i % key.length];
    }

    return base64.encode(encrypted);
  }

  /// Simple XOR-based decryption
  static String _xorDecrypt(String ciphertext, Uint8List key) {
    try {
      final encryptedBytes = base64.decode(ciphertext);
      final decrypted = Uint8List(encryptedBytes.length);

      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted[i] = encryptedBytes[i] ^ key[i % key.length];
      }

      return utf8.decode(decrypted);
    } catch (e) {
      // If decryption fails, return the original (might be unencrypted)
      return ciphertext;
    }
  }

  /// Encrypts the title and message of a note
  static Map<String, String> encryptNoteContent({
    required String title,
    required String message,
    required String userId,
  }) {
    if (userId.isEmpty) {
      throw Exception('User ID is required for encryption');
    }

    final key = _deriveKey(userId);

    return {
      'title': _xorEncrypt(title, key),
      'message': _xorEncrypt(message, key),
    };
  }

  /// Decrypts the title and message of a note
  static Map<String, String> decryptNoteContent({
    required String encryptedTitle,
    required String encryptedMessage,
    required String userId,
  }) {
    if (userId.isEmpty) {
      throw Exception('User ID is required for decryption');
    }

    final key = _deriveKey(userId);

    return {
      'title': _xorDecrypt(encryptedTitle, key),
      'message': _xorDecrypt(encryptedMessage, key),
    };
  }

  /// Helper to get current user ID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
