extension Validate on String {
  bool get isValidUserName {
    final nameRegExp =
        RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r'^\+?0[0-9]{10}$');
    return phoneRegExp.hasMatch(this);
  }

  bool get isValidEmail {
    final emailRegex = RegExp(
        r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$");
    return emailRegex.hasMatch(this);
  }

  bool get isValidPassword {
    final passRegEx = RegExp(r'^(?=.*?[a-z])(?=.*?[0-9]).{8,32}$');
    return passRegEx.hasMatch(this);
  }

  String get wellFormatted {
    return replaceAll(RegExp(r'-'), ' ');
  }
}
