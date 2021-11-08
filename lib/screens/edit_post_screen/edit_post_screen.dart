import 'package:flutter/material.dart';

import '../../models/post.dart';

import '../../widgets/sized_config.dart';
import './edit_post_additional_info.dart';
import './edit_post_building_info.dart';
import './edit_post_estate_info.dart';
import './edit_post_general_info.dart';
import './edit_post_images/edit_post_images.dart';
import './edit_post_map.dart';

class EditPostScreen extends StatefulWidget {
  static const routeName = '/edit_post';

  const EditPostScreen({Key? key}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  Post post = Post(
    id: 0,
    userType: UserType.owner,
    estateType: EstateType.house,
    dealType: DealType.sale,
    location: [],
    city: null,
    district: null,
    address: '',
    sqm: 0,
    renovation: Renovation.cosmetic,
    price: 0,
    rooms: 0,
    images: [],
    description: '',
  );

  void updatePost(Post value) {
    setState(() {
      post = value;
    });
  }

  void _prevStep() {
    if (post.step == 0) {
      Navigator.of(context).pop();
    } else {
      updatePost(post.copyWith(
        step: post.step - 1,
      ));
    }
  }

  Widget getStepWidget() {
    switch (post.step) {
      case 0:
        return EditPostGeneralInfo(
          post: post,
          updatePost: updatePost,
        );

      case 1:
        return EditPostMap(
          post: post,
          updatePost: updatePost,
        );
      case 2:
        return EditPostEstateInfo(
          post: post,
          updatePost: updatePost,
        );
      case 3:
        return EditPostBuildingInfo(
          post: post,
          updatePost: updatePost,
        );
      case 4:
        return EditPostAdditionalInfo(
          post: post,
          updatePost: updatePost,
        );
      case 5:
        return EditPostImages(
          post: post,
          updatePost: updatePost,
        );
      default:
        return EditPostGeneralInfo(
          post: post,
          updatePost: updatePost,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: post.step != 1 && post.step != 4,
      appBar: AppBar(
        title: Row(),
        leading: IconButton(
          onPressed: _prevStep,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            minHeight: SizeConfig.safeBlockVertical * 100.0,
          ),
          child: getStepWidget(),
        ),
      ),
    );
  }
}