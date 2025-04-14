import 'package:email_validator/email_validator.dart';

class Validators {
  static String? emailValidator(String? value) {
    const validTLDs = [
      '.com', '.org', '.net', '.edu', '.gov', '.info', '.biz', '.mobi',
      '.us', '.uk', '.ca', '.de', '.fr', '.jp', '.au', '.in', '.nz', '.za',
      '.it', '.br', '.cn', '.ru', '.mx', '.es', '.pt', '.nl', '.se', '.no',
      '.fi', '.dk', '.pl', '.be', '.ch', '.at', '.ie', '.tr', '.ro', '.hu',
      '.cz', '.sk', '.il', '.th', '.vn', '.ph', '.my', '.id', '.ar', '.pe',
      '.cl', '.ec', '.uy', '.ae', '.sa', '.eg', '.ng', '.ke', '.hk', '.sg',
      '.tw', '.kr', '.gr', '.co.uk', '.ac.ke', '.gov.uk', '.edu.au', '.co.za',
      '.io', '.co', '.app', '.dev', '.ai', '.xyz', '.tech', '.shop', '.online',
      '.blog', '.cloud', '.design', '.site', '.store', '.digital', '.global',
      '.world', '.live', '.tv', '.me', '.cc', '.ws', '.fm', '.am', '.health',
      '.fit', '.guru', '.club', '.events', '.news', '.media', '.money', '.bank',
      '.crypto', '.game', '.bet', '.poker', '.cars', '.auto'
    ];
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }

    bool isValid = EmailValidator.validate(value);
    if (!isValid) {
      return "Please enter a valid email address";
    }

    String domain = value.split('@').last.toLowerCase();
    bool hasValidTLD = validTLDs.any((tld) => domain.endsWith(tld));

    if(!hasValidTLD){
      return "Please enter a valid email address";
    }
    return null;
  }


  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    List errors = [];

    if (value.length < 8) {
      errors.add('Password must be at least 8 characters');
    }
    if (value.length > 15) {
      errors.add('Password must be less than 15 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add('Password must contain at least 1 uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      errors.add('Password must contain at least 1 lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      errors.add('Password must contain at least 1 number');
    }
    // if(!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)){
    //   errors.add ('Password must contain atleast 1 special character');
    // }
    if (errors.isNotEmpty) {
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

  static String? fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please fill in this field';
    }
    return null;
  }

  static String? phoneNoValidator(String? value){
    if (value == null || value.isEmpty) {
      return 'Please fill in this field';
    }
    if(value.length < 10){
      return 'Phone number must contain exactly 10 digits ';
    }
    int? test = int.tryParse(value);
    if (test == null) {
      return 'Phone number cannot contain any letters';
    }
    return null;
  }

  static String? intFieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please fill in this field';
    }
    int? test = int.tryParse(value);
    if (test == null) {
      return 'Please fill in an appropriate value. e.g. 10,50,500,4000';
    }
    return null;
  }
}
