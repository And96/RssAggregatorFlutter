class Category {
  var name = "";
  int color = 0;
  Category({
    required this.name,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json["name"],
      color: json["color"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "color": color,
    };
  }

  @override
  String toString() => '{name: $name color: $color}';
}
