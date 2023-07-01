enum ElementType {
  pyro,
  hydro,
  anemo,
  electro,
  dendro,
  cyro,
  geo,
}

class GenshinElement {
  ElementType type;
  String imagePath;

  GenshinElement({required this.type, required this.imagePath});
}
