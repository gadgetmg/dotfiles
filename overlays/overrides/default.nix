{...}: final: prev: {
  catppuccin-gtk = prev.catppuccin-gtk.override {
    variant = "mocha";
    accents = ["lavender"];
  };
}
