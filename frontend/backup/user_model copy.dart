class Product {
  final String? email;
  final String? password;
  final String? fullName;

  Product({this.email, this.password, this.fullName});

  // this is for DEBUGGING ONLY. DOES NOT CHANGE THE DATA
  @override
  String toString() {
    return 'Product( email: $email, password: $password, fullName: $fullName)';
  }
}
