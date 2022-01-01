/*
----------------------------------------------------------------------------------------------

filename: pbkdf2.dart
author: Arun_Xena
reference: https://github.com/dart-bitcoin/bip39

-----------------------------------------------------------------------------------------------
 PBKDF2 or Password-Based Key Derivation Function 2 is a simple cryptographic
key derivation pseudo-random function, which is resistant to dictionary attacks and 
rainbow table attacks. Here, it is used to Convert the mnemonic phrase produced in 
BIP-39 into a 512 bit seed 
-----------------------------------------------------------------------------------------------
*/


import 'dart:convert';
import 'dart:typed_data';

/* 
  PointyCastle is a dart library for encryption and decryption where most
  most of the classes are ports of Bouncy Castle from Java to Dart
*/
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class PBKDF2 {

  /* 
  -----------------------------------------------
  Block length can be 128, 160, 192, 224 or 256.
  The block length should be equal to the strength
  variable set in bip39.dart

        |  ENT  | CS | ENT+CS |  MS  |
        +-------+----+--------+------+
        |  128  |  4 |   132  |  12  |
        |  160  |  5 |   165  |  15  |
        |  192  |  6 |   198  |  18  |
        |  224  |  7 |   231  |  21  |
        |  256  |  8 |   264  |  24  |
  ------------------------------------------------
   */

  final int blockLength;   

  /* 
  ------------------------------------------------
  The iteration legth should be set to 2048 
  according to BIP-39
  ------------------------------------------------
   */

  final int iterationCount;

   /* 
  ------------------------------------------------
  The length of the derived key should be 
  512 bits ie, 64 bytes according to BIP-39
  ------------------------------------------------
   */

  final int keyLength;

   /* 
  ------------------------------------------------
  Salt Prefix should be "mnemonic" as per BIP-39
  ------------------------------------------------
   */

  final String saltPrefix;

   /* 
  ------------------------------------------------
              PBKDF2 Constructor
  ------------------------------------------------
   */

  PBKDF2KeyDerivator _derivator;

  PBKDF2({

    this.blockLength = 128,
    this.iterationCount = 2048,
    this.keyLength = 64,
    this.saltPrefix = "mnemonic"
  }) :_derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), blockLength));

  /* The passphrase is an empty string "", if not supplied by the user */

  Uint8List process(String mnemonic, {passPhrase = ""}) {
  final salt = Uint8List.fromList(utf8.encode(saltPrefix + passPhrase));
  _derivator.reset();
  _derivator.init(Pbkdf2Parameters(salt, iterationCount, keyLength));
  return _derivator.process(Uint8List.fromList(mnemonic.codeUnits));
}
}
