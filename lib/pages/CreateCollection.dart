import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:properly_made_nft_market/helpers/marketHelper.dart';
import 'package:properly_made_nft_market/pages/MainApplication.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Decoration/AnimatedGradient.dart';
import 'package:properly_made_nft_market/decoration/CreateCollectionDecoration.dart'
    as decoration;

import '../providers/ethereumProvider.dart';

class CreateCollectionPage extends StatefulWidget {
  const CreateCollectionPage({Key? key}) : super(key: key);

  @override
  _CreateCollectionPageState createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  File? imagePath;
  TextEditingController CollectionNameControl = new TextEditingController();
  TextEditingController CollectionDescriptionControl =
      new TextEditingController();
  TextEditingController CollectionSymbolControl =
  new TextEditingController();

  Future pickImage(type) async {
    final image = await ImagePicker().pickImage(source: type);
    if (image == null) return;
    setState(() {
      imagePath = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned(child: AnimatedGradient()),
        SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SafeArea(
                  child: Center(
                    child: Stack(
                      children: [
                        Positioned(
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.pop(context),
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainPage()),
                              ),
                            },
                            child: const Padding(
                              padding: const EdgeInsets.only(left: 16, top: 12),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                "Create Collection",
                                style: decoration.createCollectionTitle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Create a collection to Mint NFT's from, this action will cost a lot of gas, so you might want to check your wallet balance.",
                    style: decoration.createCollectionDesc,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: TextFormField(
                      style: decoration.collectionTextDecoration,
                      decoration:
                          decoration.collectionContainer("Name of Collecton"),
                      controller: CollectionNameControl,
                    )),
                Container(
                    margin: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: TextFormField(
                      style: decoration.collectionTextDecoration,
                      decoration: decoration
                          .collectionContainer("Symbol of Collection"),
                      controller: CollectionSymbolControl,
                    )),
                Container(
                    margin: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: TextFormField(
                      style: decoration.collectionTextDecoration,
                      decoration: decoration
                          .collectionContainer("Description of Collection"),
                      controller: CollectionDescriptionControl,
                    )),
                (imagePath != null)
                    ? Container(
                        width: 100, height: 100, child: Image.file(imagePath!))
                    : Text(
                        "nothing selected",
                        style: decoration.nothingSelectedDecoration,
                      ),
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
                    onTap: () => createCollection(),
                    child: Container(
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      height: 50,
                      alignment: Alignment.bottomRight,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF596EED),
                              Color(0xFFED5CAB),
                              //Color(0xFF42A5F5),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                      ),
                      child: Center(
                          child: Text(
                        "Create Collection",
                        style: decoration.createButtonTextStyle,
                      )),
                    ),
                  ),
                ),
              ],
            )),
      ]),
    );
  }

  uploadIpfs(File filePath) async {
    String credentials = "2NcZX5XIMCSEZl0ATtoOAoLjUc0:6d1b9bc5227592e7890202a88b6710c4";
    final auth = base64.encode(utf8.encode(credentials));
    var fName = filePath.path.substring(filePath.path.lastIndexOf("/") + 1);
    Dio ipfsClient = Dio(
      BaseOptions(
        baseUrl: "https://ipfs.infura.io:5001/api/v0",
        headers: {
          "Abspath": filePath.path,
          "Content-Disposition": 'form-data; filename="$fName"',
          "Authorization": "Basic $auth",
        }
      )
    );
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath.path, filename: filePath.path.substring(filePath.path.lastIndexOf("/") + 1)),
    });
    return await ipfsClient.post("/add", data: formData)
        .onError((error, stackTrace) {
      print(error);
      throw Exception(error);});
  }

  createCollection() async {

    var ipfsResult = await uploadIpfs(imagePath!);
    ipfsResult = JsonDecoder().convert(ipfsResult.toString());
    var uri = await context.read<EthereumProvider>().getMetamaskUri();
    callContract(context, "createCollection", [
        CollectionNameControl.text,
        CollectionSymbolControl.text,
        "https://cloudflare-ipfs.com/ipfs/${ipfsResult["Hash"]}",
        CollectionDescriptionControl.text
    ]);
    await launchUrlString(uri!, mode: LaunchMode.externalApplication);
  }
}
