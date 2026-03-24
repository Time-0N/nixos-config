{ pkgs, ... }:
{
  home.packages = with pkgs; [
    geist-font
  ];
  programs.kitty = {
    enable = true;
    font = {
      name = "Geist Mono";
      size = 13.0;
    };
    settings = {
      bold_font = "Geist Mono Bold";
      italic_font = "Geist Mono Italic";
      bold_italic_font = "Geist Mono Bold Italic";

      background_opacity = "0.85";
      cursor_shape = "beam";
      cursor_trail = 1;
      enable_audio_bell = "no";
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      background = "#1d2021";
      background_blur = 20;
      dynamic_background_opacity = "yes";
      window_padding_width = 5;

      scrollback_lines = 5000;

      repaint_delay = 10;
      input_delay = 1;
      sync_to_monitor = "yes";
    };
  };
}
