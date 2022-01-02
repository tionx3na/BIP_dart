import 'package:flutter/material.dart';
import 'package:bip/services/bip39/bip39.dart' as bip39;
import 'package:bip/services/bip39/pbkdf2.dart';

class MnemonicGenerator extends StatefulWidget {
  const MnemonicGenerator({Key? key}) : super(key: key);

  @override
  State<MnemonicGenerator> createState() => _MnemonicGeneratorState();
}

class _MnemonicGeneratorState extends State<MnemonicGenerator> {
  late String mnemonic;
  late dynamic seed;
  late dynamic entropy;
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50, left: 50, bottom: 20),
            color: Colors.amberAccent,
            child: const Text(
              "Enter the password",
              style: TextStyle(fontSize: 14),
            ),
          ),
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a search term',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50, left: 50),
            color: Colors.amberAccent,
            child: const Text(
              "Enter the Button to generate the mnemonics",
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(top: 50.0, left: 50),
              color: Colors.greenAccent,
              child: IconButton(
                onPressed: () {
                  password = textController.text;
                  print(password);
                  mnemonic = bip39.generateMnemonic();
                  print(mnemonic);
                  seed = bip39.mnemonicToSeedHex(mnemonic,passphrase: password);
                  print(seed);
                  entropy = bip39.mnemonicToEntropy(mnemonic);
                  print(entropy);
                },
                icon: const Icon(Icons.add),
              )),
        ],
      ),
    );
  }
}
