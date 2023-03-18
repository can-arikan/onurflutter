// Login page of the app.
// authenticate user using JWT from backend.
// Needs 2 form fields, username and password.
// User can also press Browse without logging in button to be able to browse everything without logging in.

import 'package:flutter/material.dart';
import 'package:properly_made_nft_market/Decoration/AnimatedGradient.dart';
import "package:properly_made_nft_market/Decoration/LoginDecoration.dart" as decoration;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:properly_made_nft_market/pages/MainApplication.dart';
import 'package:properly_made_nft_market/providers/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3dart/web3dart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slider_button/slider_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  var connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
          name: 'My App',
          description: 'An app for converting pictures to NFT',
          url: 'https://walletconnect.org',
          icons: [
            'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ]));

  var _session, _uri;

  loginUsingMetamask(BuildContext context) async {
    if (!connector.connected) {
      try {
        var session = await connector.createSession(onDisplayUri: (uri) async {
          _uri = uri;
          await launchUrlString(uri, mode: LaunchMode.externalApplication);
        });
        setState(() {
          _session = session;
        });
      } catch (exp) {
        print(exp);
      }
    }

    }
  getNetworkName(chainId){
    switch (chainId){
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
          //print(payload.accounts[0]);
          //print(payload.chainId);
        }));
    connector.on(
        'disconnect',
            (payload) => setState(() {
          _session = null;
        }));
    return Scaffold(
      body: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: Stack(
          children: [Positioned(child:
          AnimatedGradient(),
          ),
            Positioned(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [Padding(padding: const EdgeInsets.only(top: 100),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                    ),
                    items: decoration.imageList.map((e) =>
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Image.network(e,
                                width: 1050,
                                height: 350,
                                fit: BoxFit.cover,
                              )
                            ],
                          ),
                        )
                    ).toList(),
                  ),
                ),
                  Padding(padding: const EdgeInsets.only(top: 30),
                    child: Text("Login",
                      style: decoration.mainTextStyle,
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 30),
                    child: Text("Login",
                      style: decoration.mainTextStyle,
                    ),

                  ),
                  (_session != null) ? Container(
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
                            (_session.chainId != 5)
                                ? Row(
                              children: const [
                                Icon(Icons.warning,
                                    color: Colors.redAccent, size: 15),
                                Text('Network not supported. Switch to '),
                                Text(
                                  'Goreli Testnet',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                                : Container(alignment: Alignment.center,
                              child: SliderButton(
                                action: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MainPage()),
                                  );
                                },
                                label: const Text('Slide to login'),
                                icon: const Icon(Icons.check),
                              ),
                            )
                          ],
                      ),

                  ) :
                  ElevatedButton(
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
