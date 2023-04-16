import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:properly_made_nft_market/helpers/marketHelper.dart' as market_helper;
import 'package:properly_made_nft_market/models/Nft.dart';
import 'package:properly_made_nft_market/models/NftCollection.dart';
import 'package:web3dart/credentials.dart';
import '../backend/requests.dart';

class User {
  final String address;
  final String username;
  final String profilePicture;
  final String email;
  int nftLikes;
  int collectionLikes;

  User(
      {required this.address,
      required this.username,
      required this.profilePicture,
      required this.email,
      required this.nftLikes,
      required this.collectionLikes});

  String get pk => address;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        address: json['uAddress'],
        username: json['username'],
        profilePicture: json['profilePicture'] ?? "https://ia801703.us.archive.org/6/items/twitter-default-pfp/e.png",
        email: json['email'],
        nftLikes: json['NFTLikes'],
        collectionLikes: json["collectionLikes"]);
  }

  @override
  String toString() =>
      "User(address: $address, username: $username, profilePicture: $profilePicture, email: $email, NFTLikes: $nftLikes, collectionLikes: $collectionLikes)";

  Future<List<NFT>> get ownedNFTs async {
    var response = await market_helper.query("fetchMyNFTs", []) as List<dynamic>;
    var nfts = response.map((e) => NFT(
        address: e["collection_address"],
        nID: e["nID"],
        name: e["collection"],
        description: e["description"],
        metaDataType: "png",
        dataLink: e["tokenId"],
        collectionName: e["collectionName"],
        creator: e["creator"],
        owner: address,
        marketStatus:
        e["marketStatus"])
    );
    return nfts.toList();
  }
  Future<List<NFT>> get likedNFTs async {
    List jsonList = await getRequest("favorites", {"user": pk});
    List<NFT> ownedNFTs = jsonList.map((item) => NFT.fromJson(item)).toList();
    return ownedNFTs;
  }

  Future<bool> userLikedNFT(Map<String, dynamic> nftInfo) async {
    final List jsonList =
        await getRequest("favorites", {...nftInfo, "user": pk});
    return jsonList.isNotEmpty;
  }

  Future<bool> likeNFT(Map<String, dynamic> nftInfo,bool liked) async {
    if(liked){
      return (await deleteRequest("favorites", {...nftInfo, "user": pk}));
    }
    return (await postRequest("favorites", {...nftInfo, "user": pk}));
  }

  Future<bool> userWatchListedCollection(String address) async {
    final List jsonList =
    await getRequest("watchLists", {"nftCollection": address, "user": pk});
    return jsonList.isNotEmpty;
  }

  Future<bool> watchListCollection(String address, bool watchListed) async {
    if(watchListed){
      return (await deleteRequest("watchLists", {"nftCollection": address, "user": pk}));
    }
    return (await postRequest("watchLists", {"nftCollection": address, "user": pk}));
  }

  Future<List<NFTCollection>> get watchlistedCollections async {
    List jsonList = await getRequest("watchLists", {"user": pk});
    if (kDebugMode) {
      print(jsonList);
    }
    List<NFTCollection> watchListedCollections = jsonList.map((item) => NFTCollection.fromJson(item)).toList();

    return watchListedCollections;
  }

  Future<List<NFTCollection>> get ownedCollections async {
    var jsonList = await market_helper.query("getCollections", [EthereumAddress.fromHex(address)])
    .onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
      }
    });
    jsonList = jsonList.replaceAll("[", "").replaceAll("]", "").split(",");
    List<String> jsonStrList = jsonList;
    List<List<String>> jsonListList = List.empty(growable: true);
    for (int i = 0; i < (jsonStrList.length / 7); i++) {
      List<String> subList = List.empty(growable: true);
      for (int j = 0; j < 7; j++) {
        subList.add(jsonStrList[(i * 7) + j].trim());
      }
      jsonListList.add(subList);
    }
    List<NFTCollection> ownedCollections = jsonListList.map((item) => NFTCollection.fromJson(item)).toList();
    return ownedCollections;
  }
  Future<bool> watchLists(String address) async {
    List isCollectionFollowed = await getRequest("watchLists", {"user": pk,"nftCollection": address});
    if (kDebugMode) {
      print(isCollectionFollowed);
    }
    return (isCollectionFollowed.isNotEmpty);
  }
}
