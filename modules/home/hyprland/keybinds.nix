{ ... }:
let
  inherit (import ./variables.nix)
    mainMod
    terminal
    fileManager
    menu
    ;
in
{
  wayland.windowManager.hyprland.settings = {
    binds = {
      movefocus_cycles_fullscreen = true;
    };

    bind = [
      # Reload waybar
      "${mainMod} SHIFT, B, exec, systemctl --user restart waybar"
      # Keybinds
      "${mainMod}, RETURN, exec, ${terminal}"
      "${mainMod}, Q, killactive"
      "${mainMod} SHIFT, M, exec, wlogout"
      "${mainMod}, E, exec, ${fileManager}"
      "${mainMod}, V, togglefloating"
      "${mainMod}, SPACE, exec, ${menu}"
      "${mainMod}, F, fullscreen"
      "${mainMod}, P, pseudo"
      "${mainMod}, J, togglesplit"
      "${mainMod}, L, exec, hyprlock"
      "${mainMod}, Tab, changegroupactive, f"
      # Screenshot
      ''${mainMod} SHIFT, S, exec, grim -g "$(slurp -o -r -c '##00000000')" -t ppm - | satty --filename - --fullscreen --output-filename ~/pictures/screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png''
      # Move focus with mainMod + arrow keys
      "${mainMod}, left, movefocus, l"
      "${mainMod}, right, movefocus, r"
      "${mainMod}, up, movefocus, u"
      "${mainMod}, down, movefocus, d"
      # Switch workspaces with mainMod + [0-9]
      "${mainMod}, 1, workspace, 1"
      "${mainMod}, 2, workspace, 2"
      "${mainMod}, 3, workspace, 3"
      "${mainMod}, 4, workspace, 4"
      "${mainMod}, 5, workspace, 5"
      "${mainMod}, 6, workspace, 6"
      "${mainMod}, 7, workspace, 7"
      "${mainMod}, 8, workspace, 8"
      "${mainMod}, 9, workspace, 9"
      "${mainMod}, 0, workspace, 10"
      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "${mainMod} SHIFT, 1, movetoworkspace, 1"
      "${mainMod} SHIFT, 2, movetoworkspace, 2"
      "${mainMod} SHIFT, 3, movetoworkspace, 3"
      "${mainMod} SHIFT, 4, movetoworkspace, 4"
      "${mainMod} SHIFT, 5, movetoworkspace, 5"
      "${mainMod} SHIFT, 6, movetoworkspace, 6"
      "${mainMod} SHIFT, 7, movetoworkspace, 7"
      "${mainMod} SHIFT, 8, movetoworkspace, 8"
      "${mainMod} SHIFT, 9, movetoworkspace, 9"
      "${mainMod} SHIFT, 0, movetoworkspace, 10"
      # Scroll through existing workspaces with mainMod + scroll
      "${mainMod}, mouse_down, workspace, e+1"
      "${mainMod}, mouse_up, workspace, e-1"
      # Move window towards a direction
      "${mainMod} SHIFT, left, movewindow, l"
      "${mainMod} SHIFT, right, movewindow, r"
      "${mainMod} SHIFT, up, movewindow, u"
      "${mainMod} SHIFT, down, movewindow, d"
    ];

    bindm = [
      "${mainMod}, mouse:272, movewindow"
      "${mainMod}, mouse:273, resizewindow"
    ];

    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
