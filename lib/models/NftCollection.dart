import 'package:flutter/foundation.dart';
import 'package:web3dart/contracts.dart';

import 'Nft.dart';
import "../backend/requests.dart";
import "package:properly_made_nft_market/providers/ethereumProvider.dart" as ethereum_provider;

Future<dynamic> query(DeployedContract collectionContract, String functionName, List<dynamic> parameters) async {
  collectionContract = collectionContract;

  var contractFunction =  collectionContract.function(functionName);
  List<dynamic> response;
  try {
    response = await ethereum_provider.ethClient.call(contract: ethereum_provider.suNFTmarketContract, function: contractFunction , params: parameters);
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
  int nftLikes;

  String? get pk => address;

  NFTCollection({ this.address, required this.name, required this.description,
    required this.collectionImage,required this.category, this.numLikes = 0,
    this.nftLikes = 0, required this.owner });

  // Future<NFTCollection> fromContractAddress(String address) async {
  //   DeployedContract collectionContract = DeployedContract(ContractAbi.fromJson(const JsonEncoder().convert(CollectionAbi.abi["ABI"]), "collectionContract"), EthereumAddress.fromHex(address));
  //   await query(collectionContract, "", []);
  //
  //   return NFTCollection();
  // }

  factory NFTCollection.fromJson(List<String> json) {
    return NFTCollection(
      address: json[1],
      name: json[0],
      collectionImage: json[2],
      description: json[3],
      numLikes: int.parse(json[4]),
      owner: json[5],
      category: "TODO",
      nftLikes: int.parse(json[6]),
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
    "NFTLikes": nftLikes,
  };

  Future<List<NFT>> get NFTs async {
    List<NFT> nfts = <NFT>[];
    if (pk != null) {
        final List jsonList = await getRequest("nfts", {"collection": pk });
        nfts = jsonList.map((item) => NFT.fromJson(item)).toList();
    }
    return nfts;
  }

  @override
  String toString() => "NFTCollection(address: $address, name: $name, description: $description, collectionImage: $collectionImage, numLikes: $numLikes, owner: $owner, category: $category, NFTLikes: $nftLikes)";

}