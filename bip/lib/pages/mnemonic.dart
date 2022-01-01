import 'package:flutter/material.dart';
import 'package:bip/services/bip39/bip39.dart' as bip39; 
import 'package:bip/services/bip39/pbkdf2.dart';

class MnemonicGenerator extends StatefulWidget{
  const MnemonicGenerator({Key? key}) :super(key: key);

  @override 

  State<MnemonicGenerator> createState() => _MnemonicGeneratorState();
}

class _MnemonicGeneratorState extends State<MnemonicGenerator> {

  late String mnemonic;

  @override 

  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50, left: 50),
            color: Colors.amberAccent,
            child: const Text("Enter the Button to generate the mnemonics", style: TextStyle(fontSize: 14),),
          ),
           Container(
            margin: const EdgeInsets.only(top: 50.0, left: 50),
            color: Colors.greenAccent,
            child: IconButton(
              onPressed: () {
                mnemonic = bip39.generateMnemonic();
                print(mnemonic);
              }, 
              icon: const Icon(Icons.add),
              )
          ),
        ],
      ),
    );
  }
}