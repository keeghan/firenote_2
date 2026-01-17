# Encryption Implementation Guide

## Overview

This app now implements client-side encryption for all new notes while maintaining **backward compatibility** with existing unencrypted notes.

## How It Works

### 1. Encryption Flag (`isEncrypted`)

Each note now has an `isEncrypted` boolean field:
- **New notes**: Automatically encrypted and marked with `isEncrypted: true`
- **Old notes**: Remain unencrypted with `isEncrypted: false` (default)

### 2. Encryption Process

#### When Saving New Notes
1. User creates/edits a note in the app
2. Before saving to Firebase, the `title` and `message` are encrypted
3. The encrypted data is stored in Firebase with `isEncrypted: true`
4. The encryption key is derived from the user's UID (unique per user)

#### When Loading Notes
1. Notes are loaded from Firebase
2. If `isEncrypted: true`, the note is decrypted using the user's UID
3. If `isEncrypted: false`, the note is displayed as-is (backward compatibility)
4. Decrypted notes are displayed to the user

### 3. Security Features

- **User-specific encryption**: Each user has a unique encryption key derived from their Firebase UID
- **Deterministic key derivation**: The same user always gets the same key (using SHA-256 with 1000 iterations)
- **Transparent to users**: Encryption/decryption happens automatically
- **No key storage**: Keys are derived on-the-fly, never stored

## Modified Files

### Core Files
1. **[lib/utils/encryption_service.dart](lib/utils/encryption_service.dart)** - NEW
   - Handles all encryption/decryption operations
   - Derives encryption keys from user UID

2. **[lib/data/note.dart](lib/data/note.dart)** - MODIFIED
   - Added `isEncrypted` field
   - Updated `toMap()`, `fromMap()`, and `copy()` methods

3. **[lib/state/notes_bloc.dart](lib/state/notes_bloc.dart)** - MODIFIED
   - Added encryption when saving notes (`_onSaveNote`)
   - Added encryption when updating notes (`_onNotesUpdated`)
   - Added decryption when loading notes (`_onLoadNotes`)

## What Happens to Old Notes?

### Existing Unencrypted Notes
- **Remain readable**: Old notes without the `isEncrypted` field default to `false`
- **Continue working**: No migration needed, they work as before
- **Visible in Firebase**: Old notes remain readable in the Firebase console

### When Old Notes Are Edited
- When an old unencrypted note is edited and saved, it gets **encrypted automatically**
- The `isEncrypted` flag is set to `true`
- From that point forward, it's encrypted in Firebase

## Encryption Algorithm

Currently using **XOR-based encryption** with a SHA-256 derived key. This is suitable for basic privacy but can be upgraded:

### To Upgrade to AES Encryption

1. Add the `encrypt` package to `pubspec.yaml`:
```yaml
dependencies:
  encrypt: ^5.0.3
```

2. Replace the XOR methods in `encryption_service.dart` with AES:
```dart
import 'package:encrypt/encrypt.dart' as encrypt;

static String _aesEncrypt(String plaintext, Uint8List keyBytes) {
  final key = encrypt.Key(keyBytes);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encrypt(plaintext, iv: iv);
  return encrypted.base64;
}

static String _aesDecrypt(String ciphertext, Uint8List keyBytes) {
  final key = encrypt.Key(keyBytes);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  return encrypter.decrypt64(ciphertext, iv: iv);
}
```

## Testing

### Test New Notes
1. Create a new note
2. Check Firebase - the title and message should be encrypted (base64 gibberish)
3. Reload the app - the note should display correctly (decrypted)

### Test Old Notes
1. Old notes should display normally
2. Edit an old note
3. After saving, it should be encrypted in Firebase

### Test Multi-User
1. Create notes with User A
2. User B should NOT be able to decrypt User A's notes (different UIDs = different keys)

## Security Considerations

### Current Implementation
- Encryption key derived from Firebase UID
- Simple but effective for preventing casual database browsing
- Notes are encrypted at rest in Firebase

### Limitations
- Firebase admins with UID access could theoretically derive keys
- Not suitable for highly sensitive data without additional hardening

### Recommendations for Production
1. Use AES-256 instead of XOR
2. Consider adding a user password to the key derivation
3. Implement secure key rotation mechanism
4. Add encryption versioning for future algorithm upgrades

## Rollback Plan

If you need to disable encryption temporarily:

1. In `notes_bloc.dart`, comment out the encryption lines in `_onSaveNote` and `_onNotesUpdated`
2. Keep the decryption code active so existing encrypted notes remain readable
3. New notes will be saved unencrypted

## Migration Path (Optional)

To encrypt all existing notes:

```dart
Future<void> migrateOldNotes() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final snapshot = await FirebaseDatabase.instance.ref(userId).get();
  final data = snapshot.value as Map?;
  if (data == null) return;

  for (var entry in data.entries) {
    final noteData = Map<String, dynamic>.from(entry.value);
    if (noteData['isEncrypted'] != true) {
      final encrypted = EncryptionService.encryptNoteContent(
        title: noteData['title'] ?? '',
        message: noteData['message'] ?? '',
        userId: userId,
      );

      await FirebaseDatabase.instance.ref(userId).child(entry.key).update({
        'title': encrypted['title'],
        'message': encrypted['message'],
        'isEncrypted': true,
      });
    }
  }
}
```