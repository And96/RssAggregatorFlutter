class Category {
  var name = "";
  int color = 0;
  int icon = 0;
  Category({
    required this.name,
    required this.color,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json["name"],
      color: json["color"],
      icon: json["icon"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "color": color,
      "icon": icon,
    };
  }

  @override
  String toString() => '{name: $name color: $color}';
}
