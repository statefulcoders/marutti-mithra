import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';

enum InputType {
  email, password
}

class InputValidators {

  static String? validate(String? value, InputType type) {
    switch (type) {
      case InputType.email:
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!GetUtils.isEmail(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case InputType.password:
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < AppConfig.minPasswordLength) {
          return 'Password must be at least ${AppConfig.maxPasswordLength} characters';
        }
        if (value.length > AppConfig.maxPasswordLength) {
          return 'Password must be less than ${AppConfig.maxPasswordLength} characters';
        }
        break;
    }
    return null;
  }

  static String? validateMany(Map<String, InputType> values) {
    for (final value in values.entries) {
      final result = validate(value.key, value.value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}