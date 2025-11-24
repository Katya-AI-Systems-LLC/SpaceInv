class Barrier {
  double x;
  double y;
  double width;
  double height;
  int health;

  Barrier({
    required this.x,
    required this.y,
    this.width = 60,
    this.height = 30,
    this.health = 4,
  });
}
