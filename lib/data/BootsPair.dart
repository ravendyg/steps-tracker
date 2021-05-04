class BootsPair {
  String id;
  String name;
  double total = 0.0;

  BootsPair(this.id, this.name);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total': total,
    };
  }
}
