{ pkgs, ... }:
{
  home.packages = [
    # `lockscreen` is the single entry point used by keybinds.nix and
    # hypridle.nix, so the guard and the env fix live in exactly one place.
    #
    # qylock-lock itself comes from programs.qylock (core/displaymanager.nix),
    # already carrying QS_THEME=pixel-hollowknight and QML2_IMPORT_PATH. What
    # its wrapper does NOT set is QT_PLUGIN_PATH, and quickshell is not built
    # against qtmultimedia — so QtMultimedia loads as a QML module but finds no
    # media backend plugin, and the mp4 background renders black. Pointing at
    # qtmultimedia's plugin dir is what makes the video actually play.
    (pkgs.writeShellScriptBin "lockscreen" ''
      # hypridle fires on-timeout and before_sleep_cmd independently; without
      # this a suspend during an active lock stacks a second locker.
      if ${pkgs.procps}/bin/pgrep -f lock_shell.qml > /dev/null; then
        exit 0
      fi

      export QT_PLUGIN_PATH="${pkgs.qt6.qtmultimedia}/lib/qt-6/plugins''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
      exec /run/current-system/sw/bin/qylock-lock "$@"
    '')
  ];
}
