import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SwitchSearchViewButton extends StatefulWidget {
  final bool mapView;
  final void Function()? onPressed;

  const SwitchSearchViewButton({
    required this.mapView,
    required this.onPressed,
  });

  @override
  State<SwitchSearchViewButton> createState() => _SwitchSearchViewButtonState();
}

class _SwitchSearchViewButtonState extends State<SwitchSearchViewButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon:
          Icon(widget.mapView ? LucideIcons.alignJustify : LucideIcons.mapPin),
      label: Text(
        widget.mapView
            ? AppLocalizations.of(context)!.listView
            : AppLocalizations.of(context)!.mapView,
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8.0),
        minimumSize: const Size(50, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}
