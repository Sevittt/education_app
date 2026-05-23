import 'package:flutter/material.dart';

/// An [InheritedWidget] that provides a group value and an onChanged callback
/// to its descendants. Used to coordinate a group of [AppRadio] widgets.
class AppRadioGroup<T> extends InheritedWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const AppRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required super.child,
  });

  /// Returns the nearest [AppRadioGroup] of type [T] from the given context.
  static AppRadioGroup<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppRadioGroup<T>>();
  }

  @override
  bool updateShouldNotify(covariant AppRadioGroup<T> oldWidget) {
    return oldWidget.groupValue != groupValue || oldWidget.onChanged != onChanged;
  }
}

/// A wrapper around [Radio] that automatically uses the [AppRadioGroup] from
/// context. Must be a descendant of [AppRadioGroup].
class AppRadio<T> extends StatelessWidget {
  final T value;
  final Color? activeColor;
  final VisualDensity? visualDensity;

  const AppRadio({
    super.key,
    required this.value,
    this.activeColor,
    this.visualDensity,
  });

  @override
  Widget build(BuildContext context) {
    final group = AppRadioGroup.of<T>(context);
    // Wrap in Flutter's RadioGroup so Radio reads groupValue from context,
    // avoiding the deprecated Radio.groupValue / Radio.onChanged parameters.
    return RadioGroup<T>(
      groupValue: group?.groupValue,
      onChanged: group?.onChanged ?? (_) {},
      child: Radio<T>(
        value: value,
        activeColor: activeColor,
        visualDensity: visualDensity,
      ),
    );
  }
}

/// A wrapper around [RadioListTile] that automatically uses the [AppRadioGroup]
/// from context. Must be a descendant of [AppRadioGroup].
class AppRadioListTile<T> extends StatelessWidget {
  final T value;
  final Widget? title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool isThreeLine;
  final bool? dense;
  final EdgeInsetsGeometry? contentPadding;
  final Color? activeColor;
  final Color? selectedTileColor;
  final ListTileControlAffinity controlAffinity;

  const AppRadioListTile({
    super.key,
    required this.value,
    this.title,
    this.subtitle,
    this.secondary,
    this.isThreeLine = false,
    this.dense,
    this.contentPadding,
    this.activeColor,
    this.selectedTileColor,
    this.controlAffinity = ListTileControlAffinity.platform,
  });

  @override
  Widget build(BuildContext context) {
    final group = AppRadioGroup.of<T>(context);
    return RadioGroup<T>(
      groupValue: group?.groupValue,
      onChanged: group?.onChanged ?? (_) {},
      child: RadioListTile<T>(
        value: value,
        title: title,
        subtitle: subtitle,
        secondary: secondary,
        isThreeLine: isThreeLine,
        dense: dense,
        contentPadding: contentPadding,
        activeColor: activeColor,
        selectedTileColor: selectedTileColor,
        controlAffinity: controlAffinity,
      ),
    );
  }
}
