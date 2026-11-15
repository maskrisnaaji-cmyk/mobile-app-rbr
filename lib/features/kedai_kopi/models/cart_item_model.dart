class CartItem {
  final String name;
  final int price;
  final int quantity;
  final String note;
  final String? image;
  final String? category;

  const CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.note = '',
    this.image,
    this.category,
  });

  int get totalPrice => price * quantity;

  CartItem copyWith({
    String? name,
    int? price,
    int? quantity,
    String? note,
    String? image,
    String? category,
  }) {
    return CartItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }
}
