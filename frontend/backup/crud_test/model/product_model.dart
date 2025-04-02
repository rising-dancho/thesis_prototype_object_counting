class Product {
  final String? id;
  final String? name;
  final String? price;
  final String? desc;

  Product({this.id, this.name, this.price, this.desc});

  // this is for DEBUGGING ONLY. DOES NOT CHANGE THE DATA
  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, desc: $desc)';
  }
}
