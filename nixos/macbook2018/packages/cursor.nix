{ pkgs, ... }:
{
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 64;
    gtk.enable = true;
    x11.enable = true;
    x11.defaultCursor = "Bibata-Modern-Ice";
  };
}
