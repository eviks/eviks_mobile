import 'package:eviks_mobile/models/user.dart';
import 'package:eviks_mobile/screens/post_review_screen/post_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/pages_payload.dart';
import '../providers/auth.dart';
import './auth_screen/auth_screen.dart';
import './favorites_screen/favorites_screen.dart';
import './new_post_screen.dart';
import './user_profile_screen/user_profile_screen.dart';
import 'posts_search/posts_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Widget> _pages = [];
  int _selectedPageIndex = 0;
  var _isInit = true;
  var _isAuth = false;
  UserRole _userRole = UserRole.user;
  Map<Pages, int> pages = {};
  Map<String, dynamic>? payload = {};

  int getPageIndex() {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    final pagesAndPayload = arguments != null
        ? arguments as PagesPayload
        : PagesPayload(Pages.posts, null);
    final pageValue = pagesAndPayload.page;
    payload = pagesAndPayload.payload;
    final pageIndex = pages[pageValue] ?? 0;
    return pageIndex;
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      pages = {
        Pages.posts: 0,
        Pages.favorites: 1,
        Pages.newPost: 2,
        Pages.userProfile: 3,
      };

      final pageIndex = getPageIndex();

      setState(() {
        _selectedPageIndex = pageIndex;
        _pages = [
          PostScreen(
            url: payload?['url'] == null ? null : payload?['url'] as String,
          ),
          FavoritesScreen(
            tab: payload?['tab'] == null ? 0 : payload?['tab'] as int,
          ),
          const NewPostScreen(),
          const UserProfileScreen(),
        ];
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _selectPage(int index) {
    if (index != 0 && index != 3 && !_isAuth) {
      Navigator.pushNamed(context, AuthScreen.routeName);
    } else {
      setState(() {
        _selectedPageIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _isAuth = Provider.of<Auth>(context).isAuth;

    final currentUserRole = Provider.of<Auth>(
      context,
    ).userRole;

    if (currentUserRole == UserRole.moderator) {
      pages = {
        Pages.postReview: 0,
        Pages.posts: 1,
        Pages.favorites: 2,
        Pages.newPost: 3,
        Pages.userProfile: 4,
      };
    } else {
      pages = {
        Pages.posts: 0,
        Pages.favorites: 1,
        Pages.newPost: 2,
        Pages.userProfile: 3,
      };
    }

    final pageIndex = getPageIndex();

    if (_userRole != currentUserRole) {
      setState(() {
        _userRole = currentUserRole;
        _selectedPageIndex = pageIndex;
        _pages = [
          if (currentUserRole == UserRole.moderator) const PostReviewScreen(),
          PostScreen(
            url: payload?['url'] == null ? null : payload?['url'] as String,
          ),
          FavoritesScreen(
            tab: payload?['tab'] == null ? 0 : payload?['tab'] as int,
          ),
          const NewPostScreen(),
          const UserProfileScreen(),
        ];
      });
    }

    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _selectPage,
        selectedIndex: _selectedPageIndex,
        height: 60.0,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        destinations: [
          if (currentUserRole == UserRole.moderator)
            NavigationDestination(
              icon: const Icon(LucideIcons.shieldCheck),
              label: AppLocalizations.of(context)!.postReview,
            ),
          NavigationDestination(
            icon: const Icon(LucideIcons.search),
            label: AppLocalizations.of(context)!.tabsScreenSearch,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.heart),
            label: AppLocalizations.of(context)!.favorites,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.plusCircle),
            label: AppLocalizations.of(context)!.tabsScreenCreate,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.settings),
            label: AppLocalizations.of(context)!.tabsScreenProfile,
          ),
        ],
      ),
    );
  }
}
