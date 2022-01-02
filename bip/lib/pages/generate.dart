import 'package:flutter/material.dart';
import 'package:bip/pages/mnemonic.dart';

class GenerateMnemonic extends StatefulWidget {
  const GenerateMnemonic({Key? key}) : super(key: key);

  @override
  State<GenerateMnemonic> createState() => _GenerateMnemonic();
}

class _GenerateMnemonic extends State<GenerateMnemonic> {
  final ButtonStyle style = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Wallet"),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.greenAccent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: const Center(
              child: Text(
                "Click on Create wallet to generate a new wallet or Import a BIP-39 compliant wallet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.6,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MnemonicGenerator()),
                    );
                  },
                  child: const Text('Create Wallet'),
                ),
                ElevatedButton(
                  style: style,
                  onPressed: () {},
                  child: const Text('Import Wallet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
