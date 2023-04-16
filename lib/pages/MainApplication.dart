// main application will have 4 parts:
// Showcase
// Search
// Profile
// Mints
import 'package:flutter/material.dart';
import 'package:properly_made_nft_market/Decoration/AnimatedGradient.dart';
import "package:properly_made_nft_market/Decoration/MainApplicationDecoration.dart" as decoration;
import "package:properly_made_nft_market/pages/MainPageItems/Mint.dart";
import 'package:properly_made_nft_market/pages/MainPageItems/Search.dart';
import 'package:properly_made_nft_market/pages/MainPageItems/Showcase.dart';
import 'package:properly_made_nft_market/pages/MainPageItems/Profile.dart';


class MainPage extends StatefulWidget {
  int selectedIndex = 0;
  MainPage({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        //This is the stupidest syntax i have seen in a long time.
        body:
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                  child: AnimatedGradient()
              ),
              Positioned(
                  child: SingleChildScrollView(

                    physics: const BouncingScrollPhysics(),
                    child: ((){
                      if(widget.selectedIndex == 0)
                      {
                        return const Showcase();
                      }
                      else if(widget.selectedIndex == 1)
                      {
                        return const ProfilePage();
                      }
                      else if(widget.selectedIndex == 2)
                      {
                        return const Search();
                      }
                      else if(widget.selectedIndex == 3)
                      {
                        return const Mint();
                      }
                    })(),
                  )

              )
            ],
          ),

        ),

        //routing within widget.
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        selectedItemColor: decoration.bottomNavBarIndexColor,
        type: BottomNavigationBarType.fixed,
        backgroundColor: decoration.bottomNavBarColor,
        unselectedItemColor: decoration.bottomNavBarUnselectedIndexColor,

        //on index change, set state as that index.
        onTap: (int x)=>{
          setState(()=>{
            widget.selectedIndex = x,
          })
        },

        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Profile",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Search",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: "Create",
          )
        ],
      ),
    );
  }
}

