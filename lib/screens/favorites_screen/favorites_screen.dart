import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

import './favorites.dart';
import './subscriptions.dart';

class FavoritesScreen extends StatefulWidget {
  final int? tab;

  const FavoritesScreen({this.tab});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.tab ?? 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: AppLocalizations.of(context)!.posts),
              Tab(text: AppLocalizations.of(context)!.subscriptions),
            ],
          ),
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(LucideIcons.arrowLeft),
                )
              : null,
          title: Text(
            AppLocalizations.of(context)!.favorites,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [Favorites(), Subscriptions()],
        ),
      ),
    );
  }
}
