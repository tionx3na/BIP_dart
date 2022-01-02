import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bip/services/bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';

import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:base58check/base58check.dart';

final sha256 = SHA256Digest();
final ripemd160 = RIPEMD160Digest();

// String toP2WPKH(ECPoint publicKey) {
//   var bytes = publicKey.getEncoded(true);
//   var hashed = ripemd160.process(sha256.process(bytes));
//   return segwit.encode(Segwit('bc', 0, hashed));
// }

String toP2PKH(String publicKey) {
  // var bytes = publicKey.getEncoded(true);
  List<int> codeUnits = utf8.encode(publicKey);
  final Uint8List bytes = Uint8List.fromList(codeUnits);
  var hashed = ripemd160.process(sha256.process(bytes));
  return Base58CheckCodec.bitcoin().encode(Base58CheckPayload(0, hashed));
}



class MnemonicGenerator extends StatefulWidget {
  const MnemonicGenerator({Key? key}) : super(key: key);

  @override
  State<MnemonicGenerator> createState() => _MnemonicGeneratorState();
}

class _MnemonicGeneratorState extends State<MnemonicGenerator> {
  late String mnemonic = "";
  late dynamic seed = "";
  late dynamic entropy = "";
  late dynamic root = "";
  late dynamic pubkey = "";
  late dynamic child = "";
  String password = "";

  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: ListView(
        children: [
          Container(
              margin: const EdgeInsets.all(20),
              color: Colors.amberAccent,
              child: const Center(
                child: Text(
                  "Enter the passphrase (optional)",
                  style: TextStyle(fontSize: 14),
                ),
              )),
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter the passphrase',
            ),
          ),
          Container(
              margin: const EdgeInsets.all(20),
              color: Colors.amberAccent,
              child: const Center(
                child: Text(
                  "Enter the Button to generate the mnemonics",
                  style: TextStyle(fontSize: 14),
                ),
              )),
          Container(
              margin: const EdgeInsets.all(20),
              color: Colors.greenAccent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    password = textController.text;
                    print(password);
                    mnemonic = bip39.generateMnemonic();
                    print(mnemonic);
                    seed =
                        bip39.mnemonicToSeedHex(mnemonic, passphrase: password);
                    print(seed);
                    entropy = bip39.mnemonicToEntropy(mnemonic);
                    print(entropy);
                    final base58 =
                        bip32.BIP32.fromSeed(HEX.decode(seed) as Uint8List);
                    root = base58.toBase58();
                    bip32.BIP32 node = bip32.BIP32.fromBase58(root);
                    bip32.BIP32 nodeNeutered = node.neutered();
                    pubkey = HEX.encode(nodeNeutered.publicKey);
                    child = toP2PKH(pubkey);
                    // bip32.BIP32 path = node.derivePath('m/0/0');
                    // child = path.toBase58();
                  });
                },
                icon: const Icon(Icons.add),
              )),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Center(
                child: Text(
              "Mnemonic Phrase",
              style: TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Center(
                child: Text(
              mnemonic,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Center(
                child: Text(
              "BIP-39 Master Seed",
              style: TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Center(
                child: Text(
              seed,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Center(
                child: Text(
              "Calculated Entropy",
              style: TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Center(
                child: Text(
              entropy,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Center(
                child: Text(
              "BIP-32 Root Key",
              style: TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Center(
                child: Text(
              root.toString(),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            )),
          ),
           Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Center(
                child: Text(
              "Bitcoin BIP-32 public key",
              style: TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Center(
                child: Text(
              pubkey.toString(),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            )),
          ),
           Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Center(
                child: Text(
              "Bitcoin BIP-32 Address",
              style: TextStyle(fontSize: 20, color: Colors.grey),
              textAlign: TextAlign.center,
            )),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Center(
                child: Text(
              child.toString(),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            )),
          ),
        ],
      ),
    );
  }
}
