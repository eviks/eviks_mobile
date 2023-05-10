import 'package:eviks_mobile/icons.dart';
import 'package:eviks_mobile/models/subscription.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/subscriptions.dart';
import '../../widgets/styled_elevated_button.dart';
import '../../widgets/styled_input.dart';
import '../models/failure.dart';

class SubscriptionModal extends StatefulWidget {
  final String url;
  final String name;
  final String id;

  const SubscriptionModal(
    this.url,
    this.name,
    this.id,
  );

  @override
  State<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends State<SubscriptionModal> {
  String _name = '';
  final _formKey = GlobalKey<FormState>();
  String _errorText = '';

  @override
  Widget build(BuildContext context) {
    Future<void> subscribe() async {
      if (_formKey.currentState == null) {
        return;
      }

      _formKey.currentState!.save();

      if (!_formKey.currentState!.validate()) {
        return;
      }

      final deviceToken = await FirebaseMessaging.instance.getToken() ?? '';

      final Subscription subscription = Subscription(
        id: widget.id,
        name: _name,
        url: widget.url,
        deviceToken: deviceToken,
      );

      String errorMessage = '';
      if (!mounted) return;
      try {
        if (widget.id.isEmpty) {
          await Provider.of<Subscriptions>(context, listen: false)
              .subscribe(subscription);
        } else {
          await Provider.of<Subscriptions>(context, listen: false)
              .updateSubscription(subscription);
        }
      } on Failure catch (error) {
        if (error.statusCode >= 500) {
          errorMessage = AppLocalizations.of(context)!.serverError;
        } else {
          errorMessage = error.toString();
        }
      } catch (error) {
        errorMessage = AppLocalizations.of(context)!.unknownError;
      }

      if (errorMessage.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _errorText = errorMessage;
        });
        _formKey.currentState!.validate();
      } else {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.all(
            32.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.createSubscriptionTitle,
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
                AppLocalizations.of(context)!.createSubscriptionHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              StyledInput(
                icon: CustomIcons.search,
                title: AppLocalizations.of(context)!.subscriptionName,
                initialValue: widget.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.errorRequiredField;
                  }
                  if (_errorText.isNotEmpty) return _errorText;
                  return null;
                },
                onSaved: (value) {
                  _errorText = '';
                  _name = value ?? '';
                },
              ),
              StyledElevatedButton(
                text: AppLocalizations.of(context)!.subscribeButton,
                height: 50.0,
                onPressed: subscribe,
              ),
            ],
          ),
        ),
      ),
    );
  }
}