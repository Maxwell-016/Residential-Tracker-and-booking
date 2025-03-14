import 'package:email_validator/email_validator.dart';

class Validators{
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    bool isValid = EmailValidator.validate(value);
    if (!isValid) {
      return "Please enter a valid email address";
    }
    return null;
} 
static String ? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    List errors = [];

    if(value.length < 8){
      errors.add ('Password must be at least 8 characters');
    }
    if(value.length > 15){
      errors.add ('Password must be less than 15 characters');
    }
    if(!RegExp(r'[A-Z]').hasMatch(value)){
      errors.add ('Password must contain atleast 1 uppercase letter');
    }
    if(!RegExp(r'[a-z]').hasMatch(value)){
      errors.add ('Password must contain atleast 1 lowercase letter');
    }
    if(!RegExp(r'[0-9]').hasMatch(value)){
      errors.add  ('Password must contain atleast 1 number');
    }
    if(!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)){
      errors.add ('Password must contain atleast 1 special character');
    }
    if(errors.isNotEmpty){
      return errors.join('\n');
    }
    return null;
}
static String? confirmPasswordValidator(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
}
}