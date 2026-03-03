{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 15;
      gaps_out = 25;

      border_size = 2;

      "col.active_border" = "rgba(8080c0ee) rgba(2f3c48ee) 45deg";
      "col.inactive_border" = "rgba(00000000)";

      resize_on_border = true;
      extend_border_grab_area = 15;
      hover_icon_on_border = false;
      allow_tearing = false;

      layout = "dwindle";
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    misc = {
      disable_hyprland_logo = true;
    };

  };
}
