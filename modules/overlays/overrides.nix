{
  flake.overlays.overrides = final: prev: {
    catppuccin-gtk = prev.catppuccin-gtk.override {
      variant = "mocha";
      accents = ["lavender"];
    };
    discord = prev.discord.override {
      withOpenASAR = true;
      withVencord = true;
    };
  };
}
