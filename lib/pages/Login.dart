// Login page of the app.
// authenticate user using JWT from backend.
// Needs 2 form fields, username and password.
// User can also press Browse without logging in button to be able to browse everything without logging in.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:properly_made_nft_market/Decoration/AnimatedGradient.dart';
import "package:properly_made_nft_market/Decoration/LoginDecoration.dart" as decoration;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:properly_made_nft_market/helpers/marketHelper.dart';
import 'package:properly_made_nft_market/models/User.dart';
import 'package:properly_made_nft_market/pages/MainApplication.dart';
import 'package:properly_made_nft_market/pages/Register.dart';
import 'package:properly_made_nft_market/providers/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slider_button/slider_button.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/json_rpc.dart';

import '../providers/ethereumProvider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  var connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
          name: 'Metamask',
          description: 'An app for converting pictures to NFT',
          url: 'https://metamask.io',
          icons: [
            'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ]));
  var _session, _uri;

  init() async {
    EthereumWalletConnectProvider? x = await context.read<EthereumProvider>().getProvider();
    setState(() {
      _session = x?.connector.session;
    });
    var uriResponse = await context.read<EthereumProvider>().getMetamaskUri();
    setState(() {
      _uri = uriResponse;
    });
  }

  loginUsingMetamask(BuildContext context) async {
    if (!connector.connected) {
      await connector.createSession(chainId: 80001, onDisplayUri: (uri) async {
        setState(() {
          _uri = uri;
        });
        await launchUrlString(uri, mode: LaunchMode.externalApplication).catchError((error, stackTrace) async {
          if (error is PlatformException) {
            final url = Uri.parse(
              Platform.isAndroid
                  ? "market://details?id=io.metamask"
                  : "https://apps.apple.com/app/id1438144202",
            );
            await launchUrlString(url.toString(), mode: LaunchMode.externalApplication);
          }
        });
      });
      setState(() {
        _session = connector.session;
      });
    }
    else {
      if (_session.chainId != 80001) {
        var param = {
          "chainId": "0x${80001.toRadixString(16)}",
          "chainName": 'Mumbai Testnet',
          "nativeCurrency":
          {
            "name": 'MATIC',
            "symbol": 'MATIC',
            "decimals": 18
          },
          "rpcUrls": ['https://rpc-mumbai.maticvigil.com/'],
          "blockExplorerUrls": ['https://polygonscan.com/'],
        };
        connector.sendCustomRequest( method: 'wallet_addEthereumChain', params: [ param ]);
        await launchUrlString(_uri, mode: LaunchMode.externalNonBrowserApplication);
      }
      setState(() {
        _session = connector.session;
      });
    }
  }

  getNetworkName(chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goreli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      case 80001:
        return 'Mumbai Testnet';
      default:
        return 'Unknown Chain';
    }
  }

  @override
  Widget build(BuildContext context) {
    connector.on(
        'connect',
        (session) => setState(
              () {
                _session = _session;
              },
            ));
    connector.on(
        'session_update',
        (payload) => setState(() {
              _session = payload;
              _session = payload;
            }));
    connector.on(
        'disconnect',
        (payload) => setState(() {
              _session = null;
            }));
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              child: AnimatedGradient(),
            ),
            Positioned(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                        ),
                        items: decoration.imageList
                            .map((e) => ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Image.network(
                                        e,
                                        width: 1050,
                                        height: 350,
                                        fit: BoxFit.cover,
                                      )
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text(
                        "Login",
                        style: decoration.mainTextStyle,
                      ),
                    ),
                    (_session != null)
                        ? Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account',
                                  style: GoogleFonts.merriweather(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${_session.accounts[0]}',
                                  style: GoogleFonts.inconsolata(fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Chain: ',
                                      style: GoogleFonts.merriweather(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      getNetworkName(_session.chainId),
                                      style: GoogleFonts.inconsolata(fontSize: 16),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 20),
                                (_session.chainId != 80001)
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(top: 10),
                                                child: const Icon(Icons.warning,
                                                    color: Colors.redAccent, size: 30),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    'Network not supported. Switch to:',
                                                    style: TextStyle(color: Colors.redAccent),
                                                  ),
                                                  Text(
                                                    'Polygon Mumbai Testnet',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.redAccent),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 40,),
                                          ElevatedButton(
                                              onPressed: () => loginUsingMetamask(context),
                                              child: const Text("Change Network",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white)))
                                        ],
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        child: SliderButton(
                                          dismissible: false,
                                          action: () async {
                                            var provider = EthereumWalletConnectProvider(connector);
                                            await context.read<EthereumProvider>().setProvider(provider);
                                            await context.read<EthereumProvider>().setMetamaskUri(_uri);
                                            EthereumAddress address = EthereumAddress.fromHex(connector.session.accounts[0]);
                                            var user = await query("getUser", [address])
                                            .onError((error, stackTrace) async {
                                              if (error is RPCError) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => Register()),
                                                );
                                              }
                                              throw Exception(error);
                                            });
                                            user = user.replaceAll("[", "").replaceAll("]", "").split(",");
                                            User loggedInUser = User(
                                                address: address.toString(),
                                                username: user[0],
                                                profilePicture: user[2],
                                                email: user[1],
                                                NFTLikes: int.parse(await query("getUserLikedNFTs", [address])),
                                                collectionLikes: int.parse(await query("getUserLikedCollections", [address]))
                                            );
                                            await context.read<UserProvider>().setUser(loggedInUser);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const MainPage()),
                                            );
                                          },
                                          label: const Text('Slide to login'),
                                          icon: const Icon(Icons.check),
                                        ),
                                      )
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () => loginUsingMetamask(context),
                            child: const Text("Connect with metamask"),
                          )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
