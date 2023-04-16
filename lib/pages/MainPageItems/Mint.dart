import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import "package:properly_made_nft_market/decoration/MainPageItemsDecoration/MintDecoration.dart"
    as decoration;
import 'package:image_picker/image_picker.dart';
import 'package:properly_made_nft_market/models/NftCollection.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3dart/credentials.dart';

import '../../helpers/IpfsLoader.dart';
import '../../helpers/marketHelper.dart';
import '../../models/User.dart';
import '../../providers/UserProvider.dart';
import '../../providers/ethereumProvider.dart';
import '../CreateCollection.dart';

class Mint extends StatefulWidget {
  const Mint({Key? key}) : super(key: key);

  @override
  _MintState createState() => _MintState();
}

class _MintState extends State<Mint> {
  File? imagePath;
  TextEditingController nftNameControl = TextEditingController();
  TextEditingController nftDescriptionControl = TextEditingController();
  NFTCollection? chosenNFTCollection;

  Future pickImage(type) async {
    final image = await ImagePicker().pickImage(source: type);
    if (image == null) return;
    setState(() {
      imagePath = File(image.path);
    });
  }

  Future mintNFT() async {
    var ipfsResult = await uploadIpfs(imagePath!);
    ipfsResult = const JsonDecoder().convert(ipfsResult.toString());
    var imageIpfs = "https://cloudflare-ipfs.com/ipfs/${ipfsResult["Hash"]}";

    var json = {
      "name": nftNameControl.text,
      "description": nftDescriptionControl.text,
      "image": imageIpfs
    };

    final path = (await getApplicationDocumentsDirectory()).path;

    File newNFTjson = File("$path/mint_nft.json");

    newNFTjson = await newNFTjson
        .writeAsString(const JsonEncoder().convert(json), flush: true);

    ipfsResult = await uploadIpfs(newNFTjson);
    ipfsResult = const JsonDecoder().convert(ipfsResult.toString());
    var nftIpfs = "https://cloudflare-ipfs.com/ipfs/${ipfsResult["Hash"]}";

    var uri = await context.read<EthereumProvider>().getMetamaskUri();
    callContract(context, "createToken",
        [EthereumAddress.fromHex(chosenNFTCollection!.address!), nftIpfs]);
    await launchUrlString(uri!, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).user;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Center(
              child: Text(
                "Minting",
                style: decoration.mintTitle,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              "You can mint NFT's and create new collections from this page, all of these operations will cost money.",
              textAlign: TextAlign.center,
              style: decoration.mintDetails,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: Center(
            child: FutureBuilder<List<NFTCollection>>(
                future: user?.ownedCollections,
                builder: (context, snapshot) {
                  return DropdownButtonFormField(
                    isDense: true,
                    elevation: 0,
                    style: decoration.dropdownItemTextDecoration,
                    borderRadius: BorderRadius.circular(20),
                    dropdownColor: Colors.black,
                    decoration: decoration.collectionContainer("Collection"),
                    onChanged: (dynamic change) {
                      if (change == "NEW") {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateCollectionPage()));
                      } else {
                        if (snapshot.data != null) {
                          var idx = int.parse(change
                              .toString()
                              .substring(11, change.toString().indexOf(" (")));
                          chosenNFTCollection = snapshot.data![(idx - 1)];
                        }
                      }
                    },
                    items: [
                      if (snapshot.data != null)
                        for (int i = 0; i < snapshot.data!.length; i++) ...[
                          DropdownMenuItem(
                              value:
                                  "Collection ${i + 1} (${snapshot.data![i].name})",
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(child: Text(snapshot.data![i].name)),
                                ],
                              )),
                        ],
                      DropdownMenuItem(
                          value: "NEW",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Center(
                                  child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24,
                              )),
                            ],
                          )),
                    ],
                  );
                }),
          ),
        ),
        //NFT NAME FIELD
        Container(
            margin: const EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width * 3 / 4,
            child: TextFormField(
              style: decoration.dropdownItemTextDecoration,
              decoration: decoration.collectionContainer("Name of NFT"),
              controller: nftNameControl,
            )),
        Container(
            margin: const EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width * 3 / 4,
            child: TextFormField(
              style: decoration.dropdownItemTextDecoration,
              decoration: decoration.collectionContainer("Description of NFT"),
              controller: nftDescriptionControl,
            )),
        (imagePath != null)
            ? Center(
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: Image.file(imagePath!)))
            : Center(
                child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 3 / 4,
                child: Text("Image Not Uploaded",
                    style: decoration.nothingSelectedDecoration),
              )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => {pickImage(ImageSource.gallery)},
            child: Container(
              margin: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 1 / 4,
              height: 50,
              decoration: decoration.imagePickerDecoration,
              child: const Icon(
                Icons.image,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => {pickImage(ImageSource.camera)},
            child: Container(
              margin: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 1 / 4,
              height: 50,
              decoration: decoration.imagePickerDecoration,
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ]),
        ClipRRect(
          child: GestureDetector(
            onTap: () async {
              await mintNFT();
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
              width: MediaQuery.of(context).size.width * 1 / 2,
              height: 50,
              alignment: Alignment.bottomRight,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                gradient: LinearGradient(colors: <Color>[
                  Color(0xFF596EED),
                  Color(0xFFED5CAB),
                  //Color(0xFF42A5F5),
                ], begin: Alignment.centerLeft, end: Alignment.centerRight),
              ),
              child: Center(
                  child: Text(
                "Mint this NFT",
                style: decoration.mintButtonTextStyle,
              )),
            ),
          ),
        )
      ],
    );
  }
}
