import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';

import 'Nft.dart';
import "../backend/requests.dart";
import '../ABIs/collectionAbi.dart' as CollectionAbi;
import "package:properly_made_nft_market/providers/ethereumProvider.dart" as ethereumProvider;

Future<dynamic> query(DeployedContract collectionContract, String functionName, List<dynamic> parameters) async {
  collectionContract = collectionContract;

  var contractFunction =  collectionContract.function(functionName);
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

class NFTCollection {
  final String? address;
  final String name;
  final String? description;
  final String collectionImage;
  final String owner;
  int numLikes;
  final String? category;
  int NFTLikes;

  String? get pk => address;

  NFTCollection({ this.address, required this.name, required this.description,
    required this.collectionImage,required this.category, this.numLikes = 0,
    this.NFTLikes = 0, required this.owner });

  // Future<NFTCollection> fromContractAddress(String address) async {
  //   DeployedContract collectionContract = DeployedContract(ContractAbi.fromJson(const JsonEncoder().convert(CollectionAbi.abi["ABI"]), "collectionContract"), EthereumAddress.fromHex(address));
  //   await query(collectionContract, "", []);
  //
  //   return NFTCollection();
  // }

  factory NFTCollection.fromJson(Map<String, dynamic> json) {
    return NFTCollection(
      address: json["address"],
      name: json['name'],
      collectionImage: json['collectionImage'],
      description: json['description'],
      numLikes: json["numLikes"],
      owner: json["owner"],
      category: json["category"],
      NFTLikes: json["NFTLikes"],
    );
  }


  Map<String, dynamic> toJson() => {
    'address': address,
    'name': name,
    'description': description,
    'collectionImage':collectionImage,
    'numLikes': numLikes,
    'owner': owner,
    'category': category,
    "NFTLikes": NFTLikes,
  };

  Future<List<NFT>> get NFTs async {
    List<NFT> NFTs = <NFT>[];
    if (pk != null) {
        final List JSONList = await getRequest("nfts", {"collection": pk });
        NFTs = JSONList.map((item) => NFT.fromJson(item)).toList();
    }
    return NFTs;
  }

  @override
  String toString() => "NFTCollection(address: $address, name: $name, description: $description, collectionImage: $collectionImage, numLikes: $numLikes, owner: $owner, category: $category, NFTLikes: $NFTLikes)";

}