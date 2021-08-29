import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/posts.dart';
import '../widgets/post_item.dart';
import '../widgets/sized_config.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
    }

    final favorites = Provider.of<Auth>(context, listen: true).favorites;
    final ids = [];
    favorites.forEach((key, value) {
      if (value == true) {
        ids.add(key.toString());
      }
    });

    if (ids.isNotEmpty) {
      final Map<String, dynamic> conditions = {'ids': ids.join(',')};

      Provider.of<Posts>(context, listen: false)
          .fetchAndSetPosts(conditions)
          .then((_) => {
                setState(() {
                  _isLoading = false;
                })
              });
    } else {
      Provider.of<Posts>(context, listen: false).clearPosts();
      setState(() {
        _isLoading = false;
      });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final postsData = Provider.of<Posts>(context, listen: false);
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.favorites,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? (const Center(
              child: CircularProgressIndicator(),
            ))
          : (postsData.posts.isEmpty
              ? SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 40.0,
                            child: Image.asset(
                              "assets/img/illustrations/favorites.png",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.favoritesTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8.0,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.favoritesHint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).dividerColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (ctx, index) {
                    return PostItem(
                      id: postsData.posts[index].id,
                      estateType: postsData.posts[index].estateType,
                      price: postsData.posts[index].price,
                      rooms: postsData.posts[index].rooms,
                      sqm: postsData.posts[index].sqm,
                      city: postsData.posts[index].city,
                      district: postsData.posts[index].district,
                      images: postsData.posts[index].images,
                      floor: postsData.posts[index].floor,
                      totalFloors: postsData.posts[index].totalFloors,
                      lotSqm: postsData.posts[index].lotSqm,
                    );
                  },
                  itemCount: postsData.posts.length,
                )),
    );
  }
}