import 'package:flutter/material.dart';

class KeyboardUtils {
  // Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // Show keyboard
  static void showKeyboard(FocusNode focusNode) {
    focusNode.requestFocus();
  }

  // Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  // Dismiss keyboard on tap
  static void dismissOnTap(BuildContext context) {
    GestureDetector(
      onTap: () => hideKeyboard(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  // Move focus to next field
  static void nextFocus(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // Move focus to previous field
  static void previousFocus(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode previousFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(previousFocus);
  }

  // Check if done button pressed
  static bool isDoneAction(TextInputAction action) {
    return action == TextInputAction.done || 
           action == TextInputAction.go ||
           action == TextInputAction.send;
  }

  // Get keyboard type for email
  static TextInputType getEmailKeyboard() {
    return TextInputType.emailAddress;
  }

  // Get keyboard type for phone
  static TextInputType getPhoneKeyboard() {
    return TextInputType.phone;
  }

  // Get keyboard type for number
  static TextInputType getNumberKeyboard() {
    return TextInputType.number;
  }

  // Get keyboard type for text
  static TextInputType getTextKeyboard() {
    return TextInputType.text;
  }

  // Get keyboard type for multiline
  static TextInputType getMultilineKeyboard() {
    return TextInputType.multiline;
  }

  // Get keyboard type for URL
  static TextInputType getUrlKeyboard() {
    return TextInputType.url;
  }

  // Get keyboard action for done
  static TextInputAction getDoneAction() {
    return TextInputAction.done;
  }

  // Get keyboard action for next
  static TextInputAction getNextAction() {
    return TextInputAction.next;
  }

  // Get keyboard action for send
  static TextInputAction getSendAction() {
    return TextInputAction.send;
  }

  // Get keyboard action for search
  static TextInputAction getSearchAction() {
    return TextInputAction.search;
  }

  // Get keyboard action for go
  static TextInputAction getGoAction() {
    return TextInputAction.go;
  }
}