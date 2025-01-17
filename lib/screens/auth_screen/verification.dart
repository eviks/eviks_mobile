import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../models/failure.dart';
import '../../../providers/auth.dart';
import '../../widgets/sized_config.dart';
import '../tabs_screen.dart';

class Verification extends StatefulWidget {
  final String email;

  const Verification({required this.email, Key? key}) : super(key: key);

  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  var _isLoading = false;
  var _activationToken = '';

  Future<void> _verify() async {
    if (_activationToken.length < 5) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String errorMessage = '';
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    try {
      await Provider.of<Auth>(context, listen: false)
          .verifyUser(widget.email, _activationToken);
    } on Failure catch (error) {
      if (!mounted) return;
      if (error.statusCode >= 500) {
        errorMessage = AppLocalizations.of(context)!.serverError;
      } else {
        errorMessage = error.toString();
      }
    } catch (error) {
      if (!mounted) return;
      errorMessage = AppLocalizations.of(context)!.unknownError;
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (errorMessage.isNotEmpty) {
      showSnackBar(context, errorMessage);
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(TabsScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(LucideIcons.arrowLeft),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: SizeConfig.safeBlockHorizontal * 75.0,
            child: Column(
              children: [
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 40.0,
                  child: Image.asset(
                    "assets/img/illustrations/verification.png",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.verificationTitle,
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
                        AppLocalizations.of(context)!.verificationHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),
                ),
                PinCodeTextField(
                  appContext: context,
                  length: 5,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  enableActiveFill: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5.0),
                    activeColor: Theme.of(context).dividerColor,
                    activeFillColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).primaryColor,
                    selectedFillColor: Theme.of(context).colorScheme.surface,
                    inactiveColor: Theme.of(context).dividerColor,
                    inactiveFillColor: Theme.of(context).dividerColor,
                  ),
                  cursorColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _activationToken = value;
                    });
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  width: double.infinity,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: _verify,
                    child: _isLoading
                        ? SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.verifyButton,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
