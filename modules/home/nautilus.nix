{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nautilus
  ];

  home.file.".local/share/nautilus/scripts/Open in Kitty" = {
    text = ''
      #!/bin/sh
      if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ]; then
        dir=$(echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -1)
        [ -f "$dir" ] && dir=$(dirname "$dir")
      else
        dir="$NAUTILUS_SCRIPT_CURRENT_URI"
      fi
      dir=$(echo "$dir" | sed 's|^file://||')
      kitty --directory "$dir" &
    '';
    executable = true;
  };
}
