//register page,
//when register button is pressed get data and send user to web application with these data
//to get their ethereum address from their metamask account
//need to have form with username and password, maybe profile picture

import 'package:carousel_slider/carousel_slider.dart';
import "package:properly_made_nft_market/Decoration//RegisterDecoration.dart"
    as decoration;
import 'package:flutter/material.dart';
import 'package:properly_made_nft_market/helpers/marketHelper.dart';
import 'package:properly_made_nft_market/providers/ethereumProvider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Decoration/AnimatedGradient.dart';

class Register extends StatelessWidget {
  Register({Key? key}) : super(key: key);

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController photoController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: decoration.registerBackground,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                child: AnimatedGradient(),
              ),
              Positioned(
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
                    const SizedBox(
                      height: 30,
                    ),
                    //top text
                    Text(
                      "Register",
                      style: decoration.mainRegisterText,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "You will be taken to metamask browser in order to complete your registration",
                      style: decoration.descriptionText,
                      textAlign: TextAlign.center,
                    ),
                    //form
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: 25, left: 25, right: 25, top: 30),
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: decoration.registerFormField,
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: usernameController,
                        cursorColor: Colors.black87,
                        decoration:
                            decoration.registerUsernameFieldInputDecoration,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: 25, left: 25, right: 25),
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: decoration.registerFormField,
                      child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: Colors.black87,
                          controller: emailController,
                          decoration:
                              decoration.registerEmailFieldInputDecoration),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: 25, left: 25, right: 25),
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: decoration.registerFormField,
                      child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: Colors.black87,
                          controller: photoController,
                          decoration:
                              decoration.registerPhotoFieldInputDecoration),
                    ),
                    const SizedBox(height: 10),
                    //submit button
                    GestureDetector(
                      onTap: () async {
                        callContract(context, "createUser", [
                          usernameController.text,
                          emailController.text,
                          photoController.text
                        ]);
                        var url = await context.read<EthereumProvider>().getMetamaskUri();
                        url = url ?? (throw Exception("Metamask Url Not In Context !!!"));
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                        Navigator.popAndPushNamed(context, "login");
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1 / 2,
                          height: 50,
                          alignment: Alignment.bottomRight,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF596EED),
                                  Color(0xFFED5CAB),
                                  //Color(0xFF42A5F5),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight),
                          ),
                          child: const Center(
                            child: Text(
                              "Submit",
                              style: decoration.registerSubmitButton,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
