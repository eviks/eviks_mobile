import 'package:eviks_mobile/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../models/failure.dart';
import '../../../providers/auth.dart';
import '../../../widgets/sized_config.dart';
import '../../../widgets/styled_elevated_button.dart';
import '../../../widgets/styled_input.dart';
import '../../tabs_screen.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({
    Key? key,
  }) : super(key: key);

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  late String _displayName;
  String _newPassword = '';
  String _password = '';
  bool _isLoading = false;

  @override
  void initState() {
    _displayName =
        Provider.of<Auth>(context, listen: false).user?.displayName ?? '';
    super.initState();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState == null) {
      return;
    }

    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String _errorMessage = '';
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    try {
      await Provider.of<Auth>(context, listen: false)
          .updateProfile(_displayName, _password, _newPassword);
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
      showSnackBar(context, _errorMessage);
    } else {
      showSnackBar(context, AppLocalizations.of(context)!.profileIsUpdated);
    }
  }

  void _deleteProfile() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteProfileTitle,
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteProfileContent,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.deleteProfileCancel,
            ),
          ),
          TextButton(
            onPressed: () async {
              String _errorMessage = '';
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              try {
                await Provider.of<Auth>(context, listen: false).deleteProfile();
              } on Failure catch (error) {
                if (error.statusCode >= 500) {
                  _errorMessage = AppLocalizations.of(context)!.serverError;
                } else {
                  _errorMessage = error.toString();
                }
              } catch (error) {
                _errorMessage = AppLocalizations.of(context)!.unknownError;
              }

              if (_errorMessage.isNotEmpty) {
                showSnackBar(context, _errorMessage);
              }

              Navigator.of(context).pushNamedAndRemoveUntil(
                  TabsScreen.routeName, (route) => false);
            },
            child: Text(
              AppLocalizations.of(context)!.deleteProfileContent,
              style: TextStyle(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final bool _isGoogleUser =
        (Provider.of<Auth>(context).user?.googleId ?? '') != '';
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(CustomIcons.back),
              )
            : null,
        title: Text(
          AppLocalizations.of(context)!.profileSettings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.safeBlockHorizontal * 8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StyledInput(
                    icon: CustomIcons.user,
                    title: AppLocalizations.of(context)!.displayName,
                    initialValue: _displayName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.errorRequiredField;
                      }
                    },
                    onSaved: (value) {
                      _displayName = value ?? '';
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  StyledInput(
                    icon: CustomIcons.password,
                    title: AppLocalizations.of(context)!.password,
                    obscureText: true,
                    validator: (value) {
                      if (_newPassword.isNotEmpty) {
                        if ((value == null || value.isEmpty) &&
                            !_isGoogleUser) {
                          return AppLocalizations.of(context)!.errorPassword;
                        }
                      }
                    },
                    onSaved: (value) {
                      _password = value ?? '';
                    },
                  ),
                  StyledInput(
                    icon: CustomIcons.password,
                    title: AppLocalizations.of(context)!.newPassword,
                    obscureText: true,
                    validator: (value) {
                      if (!_isGoogleUser && _password.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.errorNewPassword;
                        } else if (value.length < 6) {
                          return AppLocalizations.of(context)!.invalidPassword;
                        }
                      } else if (value != null &&
                          value.isNotEmpty &&
                          value.length < 6) {
                        return AppLocalizations.of(context)!.invalidPassword;
                      }
                    },
                    onSaved: (value) {
                      _newPassword = value ?? '';
                    },
                  ),
                  const SizedBox(
                    height: 32.0,
                  ),
                  InkWell(
                    onTap: _deleteProfile,
                    child: Text(
                      AppLocalizations.of(context)!.deleteProfileButton,
                      style: TextStyle(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StyledElevatedButton(
          text: AppLocalizations.of(context)!.updateProfile,
          onPressed: _updateProfile,
          loading: _isLoading,
        ),
      ),
    );
  }
}
