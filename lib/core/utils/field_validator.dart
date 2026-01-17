class FieldValidators {
  FieldValidators._();

  factory FieldValidators() => _instance;
  static final FieldValidators _instance = FieldValidators._();

  String? required(String? value, String? fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is Required!";
    }
    return null;
  }

  String? name(String? value, String fieldName) {
    final namePattern = RegExp(r"^[A-Za-z]+(?: [A-Za-z]+)*$");

    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required!";
    }

    if (!namePattern.hasMatch(value.trim())) {
      return "Enter a valueid name (only alphabets allowed)!";
    }

    return null; // <-- The main fix
  }

  String? email(String? value) {
    RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );

    if (value == null || value.isEmpty) {
      return "Email is Required";
    }

    if (!emailPattern.hasMatch(value)) {
      return "Enter valid Email.";
    }
    return null;
  }

  String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    RegExp passwordPattern = RegExp(
      r"""^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?":{}|<>])(?=.*[a-zA-Z0-9!@#\$%^&*(),.?":{}|<>]).{8,}$""",
    );

    if (!passwordPattern.hasMatch(value)) {
      return "Password must be at least 8 characters, include a capital letter, a number, and a special character!";
    }
    return null;
  }

  String? maxLength(String? value, int max) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > max) {
      return "Field must not exceed $max characters!";
    }
    return null;
  }

  String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < min) {
      return "Field must be at least $min characters!";
    }
    return null;
  }

  String? pattern(String? value, String pattern, String errorMessage) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!RegExp(pattern).hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  String? rangevalueidator(num? value, num min, num max) {
    if (value == null) return null;

    if (value < min || value > max) {
      return "valueue must be between $min and $max!";
    }

    return null;
  }

  String? datevalueidator(DateTime? date, {DateTime? min, DateTime? max}) {
    if (date == null) return null;

    if (min != null && date.isBefore(min)) {
      return "Date must be after ${min.toIso8601String()}!";
    }
    if (max != null && date.isAfter(max)) {
      return "Date must be before ${max.toIso8601String()}!";
    }
    return null;
  }

  String? lengthvalueidator(String? value, int length) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length != length) {
      return "Field must be exactly $length characters!";
    }

    return null;
  }

  String? multiCheck(
    String? value,
    List<String? Function(String?)> valueidators,
  ) {
    for (var valueidator in valueidators) {
      final result = valueidator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  String? mobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required!';
    }

    // final pattern = r'^\+?[1-9]\d{10,15}$';
    // if (!RegExp(pattern).hasMatch(value.trim())) {
    //   return 'Please enter a valueid international phone number';
    // }

    if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
      return 'Please enter a valueid mobile number!';
    }

    return null;
  }

  String? match(String? value, String matchvalueue, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the password!';
    }

    // final pattern = r'^\+?[1-9]\d{10,15}$';
    // if (!RegExp(pattern).hasMatch(value.trim())) {
    //   return 'Please enter a valueid international phone number';
    // }

    if (value != matchvalueue) {
      return errorMessage;
    }

    return null;
  }
}
