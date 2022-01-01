/*
----------------------------------------------------------------------------------------------

filename: bip39.dart
author: Arun_Xena
reference: https://github.com/dart-bitcoin/bip39

-----------------------------------------------------------------------------------------------
 BIP-39 describes the implementation of a mnemonic code or mnemonic sentence for the generation 
 of deterministic wallets.It consists of two parts, generating the mnemonic and converting it 
 into a binary seed. This seed can then later be used to generate deterministic wallets using 
 BIP-32 or similar methods.
-----------------------------------------------------------------------------------------------
*/


import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' show sha256;
import 'package:hex/hex.dart';
import 'package:bip/services/bip39/pbkdf2.dart';
import 'package:bip/services/bip39/wordlist.dart';

/*
---------------------------------------------------------------
 _SIZE_BYTE is the length of the entropy, which is a randomly 
 generated bits. Its length should be between 128 to 256.
---------------------------------------------------------------
 */

const int _SIZE_BYTE = 255;

// constant strings

const _INVALID_MNEMONIC = 'Invalid mnemonic';
const _INVALID_ENTROPY = 'Invalid entropy';
const _INVALID_CHECKSUM = 'Invalid mnemonic checksum';

/* 
-----------------------------------------
Defining a Uint8List called RandomBytes 
-----------------------------------------
*/

typedef Uint8List RandomBytes(int size);


/* 
--------------------------------------------------
Conversion of binary to bytes and bytes to binary 
--------------------------------------------------
*/

int _binaryToByte(String binary) {
  return int.parse(binary, radix: 2);
}

String _bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}

/* 
------------------------------------------------------
  Derivation of Checksum bits according to BIP-39

  checksum = ENT / 32
  This checksum is then appended to the initial entropy
------------------------------------------------------
 */

String _deriveChecksumBits(Uint8List entropy) {
  final ENT = entropy.length * 8;
  final CS = ENT ~/ 32;
  final hash = sha256.convert(entropy);
  return _bytesToBinary(Uint8List.fromList(hash.bytes)).substring(0, CS);
}

/* 
--------------------------
  Random Bytes generator
--------------------------
 */

Uint8List _randomBytes(int size) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(_SIZE_BYTE);
  }
  return bytes;
}

/* 
-----------------------------------------------------------------
Generating the mnemonic by converting the entropy to mnemonic 

The variable 'strength' could be 128,160,192,224 0r 256.

        |  ENT  | CS | ENT+CS |  MS  |
        +-------+----+--------+------+
        |  128  |  4 |   132  |  12  |
        |  160  |  5 |   165  |  15  |
        |  192  |  6 |   198  |  18  |
        |  224  |  7 |   231  |  21  |
        |  256  |  8 |   264  |  24  |

The concatenated bits are split into groups of 11 bits, each 
encoding a number from 0-2047, serving an index into a wordlist.
-----------------------------------------------------------------
*/

String generateMnemonic(
    {int strength = 128, RandomBytes randomBytes = _randomBytes}) {
  assert(strength % 32 == 0);
  final entropy = randomBytes(strength ~/ 8);
  return entropyToMnemonic(HEX.encode(entropy));
}

String entropyToMnemonic(String entropyString) {
  final entropy = Uint8List.fromList(HEX.decode(entropyString));
  if (entropy.length < 16) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length > 32) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length % 4 != 0) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  final entropyBits = _bytesToBinary(entropy);
  final checksumBits = _deriveChecksumBits(entropy);
  final bits = entropyBits + checksumBits;
  final regex = new RegExp(r".{1,11}", caseSensitive: false, multiLine: false);
  final chunks = regex
      .allMatches(bits)
      .map((match) => match.group(0)!)
      .toList(growable: false);
  List<String> wordlist = WORDLIST;
  String words =
      chunks.map((binary) => wordlist[_binaryToByte(binary)]).join(' ');
  return words;
}

/*
----------------------------------- 
Generating Seed from Mnemonic
It uses pbkdf2 class from the 
dart file named the same.

If the user does nont enter a 
passphrase, then the passphrase
remains to be an empty string.
-----------------------------------
 */

Uint8List mnemonicToSeed(String mnemonic, {String passphrase = ""}) {
  final pbkdf2 = new PBKDF2();
  return pbkdf2.process(mnemonic, passPhrase: passphrase);
}

// String mnemonicToSeedHex(String mnemonic, {String passphrase = ""}) {
//   final seed = mnemonicToSeed(mnemonic);
//   return HEX.encode(seed);
//   }

String mnemonicToSeedHex(String mnemonic, {String passphrase = ""}) {
  return mnemonicToSeed(mnemonic, passphrase: passphrase).map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}

bool validateMnemonic(String mnemonic) {
  try {
    mnemonicToEntropy(mnemonic);
  } catch (e) {
    return false;
  }
  return true;
}

/* 
------------------------------------
Conversion of mnemonic to entropy
------------------------------------
 */

String mnemonicToEntropy(mnemonic) {
  var words = mnemonic.split(' ');
  if (words.length % 3 != 0) {
    throw new ArgumentError(_INVALID_MNEMONIC);
  }
  final wordlist = WORDLIST;
  // convert word indices to 11 bit binary strings
  final bits = words.map((word) {
    final index = wordlist.indexOf(word);
    if (index == -1) {
      throw new ArgumentError(_INVALID_MNEMONIC);
    }
    return index.toRadixString(2).padLeft(11, '0');
  }).join('');
  // split the binary string into ENT/CS
  final dividerIndex = (bits.length / 33).floor() * 32;
  final entropyBits = bits.substring(0, dividerIndex);
  final checksumBits = bits.substring(dividerIndex);

  // calculate the checksum and compare
  final regex = RegExp(r".{1,8}");
  final entropyBytes = Uint8List.fromList(regex
      .allMatches(entropyBits)
      .map((match) => _binaryToByte(match.group(0)!))
      .toList(growable: false));
  if (entropyBytes.length < 16) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length > 32) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length % 4 != 0) {
    throw StateError(_INVALID_ENTROPY);
  }
  final newChecksum = _deriveChecksumBits(entropyBytes);
  if (newChecksum != checksumBits) {
    throw StateError(_INVALID_CHECKSUM);
  }
  return entropyBytes.map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}


