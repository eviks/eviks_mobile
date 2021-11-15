import 'package:eviks_mobile/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/failure.dart';
import '../../models/post.dart';
import '../../providers/auth.dart';
import '../../providers/posts.dart';
import '../../widgets/sized_config.dart';
import '../../widgets/styled_elevated_button.dart';
import '../../widgets/styled_input.dart';
import '../tabs_screen.dart';
import './step_title.dart';

class EditPostContacts extends StatefulWidget {
  const EditPostContacts({
    Key? key,
  }) : super(key: key);

  @override
  _EditPostContactsState createState() => _EditPostContactsState();
}

class _EditPostContactsState extends State<EditPostContacts> {
  late Post? postData;
  bool _confirmPost = false;

  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

  String? _contact;

  @override
  void initState() {
    postData = Provider.of<Posts>(context, listen: false).postData;

    if ((postData?.lastStep ?? -1) >= 7) {
      _contact = postData?.contact;
    }

    super.initState();
  }

  void _onPostConfirm() {
    if (_formKey.currentState == null) {
      return;
    }

    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _confirmPost = true;
    _updatePost();
    _createPost();
  }

  void _updatePost({bool notify = true}) {
    Provider.of<Posts>(context, listen: false).updatePost(
        postData?.copyWith(
          contact: _contact,
          username:
              Provider.of<Auth>(context, listen: false).user?.displayName ?? '',
          lastStep: 7,
        ),
        notify: notify);
  }

  void _createPost() async {
    if (postData == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String _errorMessage = '';
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    try {
      await Provider.of<Posts>(context, listen: false)
          .createPost(postData!.copyWith(
        contact: _contact,
        username:
            Provider.of<Auth>(context, listen: false).user?.displayName ?? '',
        lastStep: 7,
      ));
    } on Failure catch (error) {
      if (error.statusCode >= 500) {
        _errorMessage = AppLocalizations.of(context)!.serverError;
      } else {
        _errorMessage = error.toString();
      }
    } catch (error) {
      _errorMessage = AppLocalizations.of(context)!.unknownError;
    }

    setState(() {
      _isLoading = false;
    });

    if (_errorMessage.isNotEmpty) {
      displayErrorMessage(context, _errorMessage);
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(TabsScreen.routeName, (route) => false);
  }

  @override
  void deactivate() {
    if (!_confirmPost) {
      _formKey.currentState?.save();
      _updatePost(notify: false);
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockHorizontal * 15.0,
                8.0, SizeConfig.safeBlockHorizontal * 15.0, 32.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StepTitle(
                      title: AppLocalizations.of(context)!.contactTitle,
                      icon: CustomIcons.phonering,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    SizedBox(
                      height: SizeConfig.safeBlockVertical * 30.0,
                      child: Image.asset(
                        "assets/img/illustrations/post_confirm.png",
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.postAlmostCreated,
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
                      AppLocalizations.of(context)!.postAlmostCreatedHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    StyledInput(
                      icon: CustomIcons.phone,
                      title: AppLocalizations.of(context)!.phoneNumber,
                      initialValue: _contact,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .errorRequiredField;
                        }
                      },
                      onSaved: (value) {
                        _contact = value ?? '';
                      },
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: const Offset(10.0, 10.0),
                )
              ],
            ),
            child: StyledElevatedButton(
              text: AppLocalizations.of(context)!.submitPost,
              onPressed: _onPostConfirm,
              loading: _isLoading,
              width: SizeConfig.safeBlockHorizontal * 100.0,
              suffixIcon: CustomIcons.checked,
            ),
          ),
        ),
      ],
    );
  }
}