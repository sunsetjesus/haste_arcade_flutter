class Error {
  final String message;
  final int code;
  Error(this.message, this.code);
}

class AppError {
  static Error undefined = Error("Something went wrong", 111);
  static Error nullData = Error("Data not found", 112);
}
