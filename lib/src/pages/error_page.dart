import 'package:flutter/material.dart';

import '../widgets/error_dialog_box.dart';

// ignore: must_be_immutable
class ErrorPage extends StatelessWidget {
  final Widget _exceptionPageName;
  String _errorMessage;

  ErrorPage(
      {Key? key, required Widget exceptionPageName, required String errorMessage})
      :
        _exceptionPageName = exceptionPageName,
        _errorMessage = errorMessage,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // handled errors opens dialog box instead new page
    if ("${_errorMessage}".contains("NoSuchMethodError: The method '[]' was called on null")) {
      _errorMessage = "No such data was found";
        return ErrorDialogBox(exceptionPageName: _exceptionPageName, errorMessage: _errorMessage);
    }
    if ("${_errorMessage}".contains(
        "Failed User Load Exception: Failed to get USER")) {
      _errorMessage =
      "Wrong username or requested user\n is restricted/unfound";
      return ErrorDialogBox(
          exceptionPageName: _exceptionPageName, errorMessage: _errorMessage);
    }
    // else any other errors opens error dialog box
    return ErrorDialogBox(
        exceptionPageName: _exceptionPageName, errorMessage: _errorMessage);
  }
}