import 'product.dart';

class CartItem {
  final Product product;
  String size;
  int quantity;

  CartItem({required this.product, this.size = 'M', this.quantity = 1});

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'size': size,
      'quantity': quantity,
    };
  }
}
