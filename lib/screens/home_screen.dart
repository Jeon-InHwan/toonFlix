import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_model.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/webtoon_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences prefs;
  late Future<List<WebtoonModel>> webtoon;
  bool noFavorites = true;

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons == null) {
      await prefs.setStringList('likedToons', []);
    } else {
      if (likedToons.isNotEmpty) {
        noFavorites = false;
      } else {
        noFavorites = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getTodaysToons();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 8,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        title: const Text(
          "ToonFlix",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: FutureBuilder(
        future: webtoon,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 25,
                    bottom: 15,
                  ),
                  child: const Text(
                    "Today's upload",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: makeList(snapshot),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 25,
                    bottom: 15,
                  ),
                  child: const Text(
                    "Your favorites",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                noFavorites
                    ? Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                offset: const Offset(10, 10),
                                color: Colors.black.withOpacity(0.5),
                              )
                            ]),
                        width: 180,
                        height: 220,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Empty',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 300,
                        child: makeListForFavorites(snapshot),
                        //
                      ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<WebtoonModel>> snapshot) {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          var webtoon = snapshot.data![index];
          return Webtoon(
            title: webtoon.title,
            thumb: webtoon.thumb,
            id: webtoon.id,
            favorite: false,
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 40,
          );
        });
  }

  ListView makeListForFavorites(AsyncSnapshot<List<WebtoonModel>> snapshot) {
    final likedToons = prefs.getStringList('likedToons');
    List<WebtoonModel> showingList = [];

    for (var element in snapshot.data!) {
      if (likedToons != null && likedToons.isNotEmpty) {
        for (var likedToon in likedToons) {
          if (element.id == likedToon) {
            showingList.add(element);
          }
        }
      }
    }

    return ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: likedToons == null ? 0 : likedToons.length,
        itemBuilder: (context, index) {
          if (likedToons != null || likedToons!.isNotEmpty) {
            var webtoon = showingList[index];
            return Webtoon(
              title: webtoon.title,
              thumb: webtoon.thumb,
              id: webtoon.id,
              favorite: true,
            );
          }
          return null;
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 40,
          );
        });
  }
}
