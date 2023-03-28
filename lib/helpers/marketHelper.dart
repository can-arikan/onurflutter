import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import "package:properly_made_nft_market/providers/ethereumProvider.dart" as ethereumProvider;
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../models/Credentials.dart';


Future<dynamic> query(String functionName, List<dynamic> parameters) async{
  var contractFunction =  ethereumProvider.suNFTmarketContract.function(functionName);
  List<dynamic> response;
  try {
    response = await ethereumProvider.ethClient.call(contract: ethereumProvider.suNFTmarketContract, function: contractFunction , params: parameters);
  } catch (error, trace) {
    if (kDebugMode) {
      print(error);
    }
    if (kDebugMode) {
      print(trace);
    }
    rethrow;
  }
  return response[0].toString();
}

Future<dynamic> callContract(BuildContext context, String functionName, List<dynamic> parameters) async {
  var contractFunction =  ethereumProvider.suNFTmarketContract.function(functionName);
  var provider = await context.read<ethereumProvider.EthereumProvider>().getProvider();
  provider = provider ?? (throw Exception("Provider Is Not In The Context !!!"));
  var cred = WalletConnectEthereumCredentials(provider: provider!);
  List<dynamic> response;
  try {
    var response2 = await ethereumProvider.ethClient.sendTransaction(
        cred,
        Transaction.callContract(
          contract: ethereumProvider.suNFTmarketContract,
          function: contractFunction,
          parameters: parameters,
          from: EthereumAddress.fromHex(
              cred.provider.connector.session.accounts[0]),
        ),
        chainId: 80001
    );
    response = response2 as List;
  } catch (error, trace) {
    if (kDebugMode) {
      print(error);
    }
    if (kDebugMode) {
      print(trace);
    }
    rethrow;
  }
  return response[0].toString();
}