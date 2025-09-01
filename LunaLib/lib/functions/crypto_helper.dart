import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart' as pc;

/// Helper class for cryptographic operations
class CryptoHelper {
  /// Compute hash using specified algorithm
  static String computeHash(String input, String algorithm) {
    final bytes = utf8.encode(input);

    switch (algorithm.toUpperCase()) {
      case 'SHA1':
        return sha1.convert(bytes).toString();
      case 'SHA256':
        return sha256.convert(bytes).toString();
      case 'SHA384':
        return sha384.convert(bytes).toString();
      case 'SHA512':
        return sha512.convert(bytes).toString();
      case 'MD5':
        return md5.convert(bytes).toString();
      default:
        throw ArgumentError('Unsupported hash algorithm: $algorithm');
    }
  }

  /// Compute HMAC using specified algorithm and key
  static String computeHmac(String input, String key, String algorithm,
      bool hmacBase64, bool keyBase64) {
    List<int> keyBytes;
    if (keyBase64) {
      try {
        keyBytes = base64Decode(key);
      } catch (e) {
        throw ArgumentError('Invalid base64 key: $key');
      }
    } else {
      keyBytes = utf8.encode(key);
    }

    final inputBytes = utf8.encode(input);

    // Compute HMAC
    List<int> hmacBytes;
    switch (algorithm.toUpperCase()) {
      case 'SHA1':
        final hmacInstance = Hmac(sha1, keyBytes);
        hmacBytes = hmacInstance.convert(inputBytes).bytes;
        break;
      case 'SHA256':
        final hmacInstance = Hmac(sha256, keyBytes);
        hmacBytes = hmacInstance.convert(inputBytes).bytes;
        break;
      case 'SHA384':
        final hmacInstance = Hmac(sha384, keyBytes);
        hmacBytes = hmacInstance.convert(inputBytes).bytes;
        break;
      case 'SHA512':
        final hmacInstance = Hmac(sha512, keyBytes);
        hmacBytes = hmacInstance.convert(inputBytes).bytes;
        break;
      case 'MD5':
        final hmacInstance = Hmac(md5, keyBytes);
        hmacBytes = hmacInstance.convert(inputBytes).bytes;
        break;
      default:
        throw ArgumentError('Unsupported HMAC algorithm: $algorithm');
    }

    // Return result
    if (hmacBase64) {
      return base64Encode(hmacBytes);
    } else {
      return hmacBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    }
  }

  /// AES encrypt with specific key and IV
  static String aesEncryptWithIV(
      String plaintext, String keyBase64, String ivBase64,
      {String mode = 'CBC', String padding = 'PKCS7'}) {
    try {
      // Decode base64 key and IV
      final keyBytes = base64Decode(keyBase64);
      final ivBytes = base64Decode(ivBase64);

      // Validate key size (16, 24, or 32 bytes for AES-128, AES-192, AES-256)
      if (![16, 24, 32].contains(keyBytes.length)) {
        throw ArgumentError(
            'Invalid AES key size: ${keyBytes.length} bytes. Must be 16, 24, or 32 bytes.');
      }

      // Validate IV size (16 bytes for AES)
      if (ivBytes.length != 16) {
        throw ArgumentError(
            'Invalid AES IV size: ${ivBytes.length} bytes. Must be 16 bytes.');
      }

      final key = Key(Uint8List.fromList(keyBytes));
      final iv = IV(Uint8List.fromList(ivBytes));

      // Select AES mode
      AESMode aesMode;
      switch (mode.toUpperCase()) {
        case 'CBC':
          aesMode = AESMode.cbc;
          break;
        case 'ECB':
          aesMode = AESMode.ecb;
          break;
        case 'CFB':
          aesMode = AESMode.cfb64;
          break;
        case 'OFB':
          aesMode = AESMode.ofb64;
          break;
        case 'CTR':
          aesMode = AESMode.ctr;
          break;
        default:
          aesMode = AESMode.cbc;
      }

      // Create encrypter with specified mode
      final encrypter = Encrypter(AES(key, mode: aesMode));

      // Encrypt the plaintext
      final encrypted = aesMode == AESMode.ecb
          ? encrypter.encrypt(plaintext)
          : encrypter.encrypt(plaintext, iv: iv);

      // Return base64-encoded ciphertext
      return encrypted.base64;
    } catch (e) {
      throw Exception('AES encryption failed: $e');
    }
  }

  /// AES decrypt with specific key and IV
  static String aesDecryptWithIV(
      String ciphertextBase64, String keyBase64, String ivBase64,
      {String mode = 'CBC', String padding = 'PKCS7'}) {
    try {
      // Decode base64 inputs
      final keyBytes = base64Decode(keyBase64);
      final ivBytes = base64Decode(ivBase64);

      // Validate key size
      if (![16, 24, 32].contains(keyBytes.length)) {
        throw ArgumentError(
            'Invalid AES key size: ${keyBytes.length} bytes. Must be 16, 24, or 32 bytes.');
      }

      // Validate IV size
      if (ivBytes.length != 16) {
        throw ArgumentError(
            'Invalid AES IV size: ${ivBytes.length} bytes. Must be 16 bytes.');
      }

      final key = Key(Uint8List.fromList(keyBytes));
      final iv = IV(Uint8List.fromList(ivBytes));
      final encrypted = Encrypted.fromBase64(ciphertextBase64);

      // Select AES mode
      AESMode aesMode;
      switch (mode.toUpperCase()) {
        case 'CBC':
          aesMode = AESMode.cbc;
          break;
        case 'ECB':
          aesMode = AESMode.ecb;
          break;
        case 'CFB':
          aesMode = AESMode.cfb64;
          break;
        case 'OFB':
          aesMode = AESMode.ofb64;
          break;
        case 'CTR':
          aesMode = AESMode.ctr;
          break;
        default:
          aesMode = AESMode.cbc;
      }

      // Create decrypter with specified mode
      final encrypter = Encrypter(AES(key, mode: aesMode));

      // Decrypt the ciphertext
      final decrypted = aesMode == AESMode.ecb
          ? encrypter.decrypt(encrypted)
          : encrypter.decrypt(encrypted, iv: iv);

      return decrypted;
    } catch (e) {
      throw Exception('AES decryption failed: $e');
    }
  }

  /// AES encrypt with secret key using AES-256-CBC
  static String aesEncrypt(String plaintext, String secretKey) {
    try {
      // Generate a key from the secret key
      final keyBytes = _generateAESKey(secretKey);
      final key = Key(keyBytes);

      // Generate a random IV (16 bytes for AES)
      final iv = IV.fromSecureRandom(16);

      // Create encrypter
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Encrypt the plaintext
      final encrypted = encrypter.encrypt(plaintext, iv: iv);

      // Combine IV and encrypted data
      final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);

      return base64Encode(combined);
    } catch (e) {
      throw Exception('AES encryption failed: $e');
    }
  }

  /// AES decrypt with secret key using AES-256-CBC
  static String aesDecrypt(String ciphertext, String secretKey) {
    try {
      // Decode base64
      final combined = base64Decode(ciphertext);

      // Extract IV (first 16 bytes) and encrypted data (rest)
      if (combined.length < 16) {
        throw Exception('Invalid ciphertext: too short');
      }

      final ivBytes = combined.sublist(0, 16);
      final encryptedBytes = combined.sublist(16);

      final iv = IV(ivBytes);
      final encrypted = Encrypted(encryptedBytes);

      // Generate the same key from secret key
      final keyBytes = _generateAESKey(secretKey);
      final key = Key(keyBytes);

      // Create decrypter
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Decrypt
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return decrypted;
    } catch (e) {
      throw Exception('AES decryption failed: $e');
    }
  }

  /// Generate a 32-byte AES key from a secret key string
  static Uint8List _generateAESKey(String secretKey) {
    // Use SHA-256 to generate a consistent 32-byte key from any input
    final digest = sha256.convert(utf8.encode(secretKey));
    return Uint8List.fromList(digest.bytes);
  }

  /// RSA encrypt with public key
  static String rsaEncrypt(
      String plaintext, String modulus, String exponent, bool oaep) {
    try {
      // Parse modulus and exponent from base64
      final n = pc.RSAPublicKey(
        _base64ToBigInt(modulus),
        _base64ToBigInt(exponent),
      );

      // Create RSA engine with appropriate padding
      final cipher = oaep
          ? pc.OAEPEncoding(pc.RSAEngine())
          : pc.PKCS1Encoding(pc.RSAEngine());

      cipher.init(true, pc.PublicKeyParameter<pc.RSAPublicKey>(n));

      final input = utf8.encode(plaintext);
      final encrypted = cipher.process(Uint8List.fromList(input));

      return base64Encode(encrypted);
    } catch (e) {
      throw Exception('RSA encryption failed: $e');
    }
  }

  /// RSA encrypt with PKCS1PAD2 padding
  static String rsaPKCS1PAD2(
      String message, String modulusHex, String exponentHex) {
    try {
      // Convert hex to BigInt
      final n = BigInt.parse('0x$modulusHex');
      final e = BigInt.parse('0x$exponentHex');

      // Calculate key size in bytes
      final keySize = (n.bitLength + 7) ~/ 8;

      // PKCS1 v1.5 padding
      final paddedMessage = _pkcs1Pad2(message, keySize);

      // RSA encryption: c = m^e mod n
      final encrypted = paddedMessage.modPow(e, n);

      // Convert to base64
      final bytes = _bigIntToBytes(encrypted, keySize);
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('RSA PKCS1PAD2 encryption failed: $e');
    }
  }

  /// PBKDF2 PKCS5 key derivation
  static String pbkdf2PKCS5(String password, String salt, int saltSize,
      int iterations, int keySize, String algorithm) {
    try {
      Uint8List saltBytes;

      if (salt.isNotEmpty) {
        // Use provided salt
        saltBytes = base64Decode(salt);
      } else {
        // Generate random salt
        final random = pc.SecureRandom('Fortuna')
          ..seed(pc.KeyParameter(Uint8List.fromList(List.generate(
              32, (i) => DateTime.now().millisecondsSinceEpoch ~/ (i + 1)))));
        saltBytes = random.nextBytes(saltSize);
      }

      // Select hash algorithm
      pc.Digest digest;
      switch (algorithm.toUpperCase()) {
        case 'SHA1':
          digest = pc.SHA1Digest();
          break;
        case 'SHA256':
          digest = pc.SHA256Digest();
          break;
        case 'SHA384':
          digest = pc.SHA384Digest();
          break;
        case 'SHA512':
          digest = pc.SHA512Digest();
          break;
        case 'MD5':
          digest = pc.MD5Digest();
          break;
        default:
          digest = pc.SHA1Digest();
      }

      // Generate key using PBKDF2
      final params = pc.Pbkdf2Parameters(saltBytes, iterations, keySize);
      final keyDerivator = pc.PBKDF2KeyDerivator(pc.HMac(digest, 64))
        ..init(params);

      final key = keyDerivator.process(utf8.encode(password));

      return base64Encode(key);
    } catch (e) {
      throw Exception('PBKDF2 key derivation failed: $e');
    }
  }

  static BigInt _base64ToBigInt(String base64) {
    final bytes = base64Decode(base64);
    return _bytesToBigInt(bytes);
  }

  static BigInt _bytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt bigInt, int length) {
    final bytes = Uint8List(length);
    var value = bigInt;

    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (value & BigInt.from(0xFF)).toInt();
      value = value >> 8;
    }

    return bytes;
  }

  static BigInt _pkcs1Pad2(String message, int keySize) {
    if (keySize < message.length + 11) {
      throw Exception('Message too long for RSA');
    }

    final buffer = Uint8List(keySize);
    final messageBytes = utf8.encode(message);
    int i = message.length - 1;

    // Copy message bytes to end of buffer
    for (int j = keySize - 1; j >= keySize - messageBytes.length; j--) {
      buffer[j] = messageBytes[i--];
    }

    // Add padding
    int padLength = keySize - messageBytes.length - 3;
    final random = pc.SecureRandom('Fortuna')
      ..seed(pc.KeyParameter(Uint8List.fromList(List.generate(
          32, (i) => DateTime.now().millisecondsSinceEpoch ~/ (i + 1)))));

    // Fill with random non-zero bytes
    for (int j = 2; j < 2 + padLength; j++) {
      int randomByte;
      do {
        randomByte = random.nextUint8();
      } while (randomByte == 0);
      buffer[j] = randomByte;
    }

    buffer[0] = 0x00;
    buffer[1] = 0x02;
    buffer[2 + padLength] = 0x00;

    return _bytesToBigInt(buffer);
  }
}
