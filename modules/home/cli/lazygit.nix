{
  lib,
  ...
}:
let
  accent = "#88c0d0";
  muted = "#4c566a";
in
{
  programs.lazygit = {
    enable = true;
    settings = lib.mkForce {
      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
      update.method = "never";
      git = {
        commit.signOff = true;
        parseEmoji = true;
      };
      gui = {
        theme = {
          activeBorderColor = [
            accent
            "bold"
          ];
          inactiveBorderColor = [ muted ];
        };
        showListFooter = false;
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        nerdFontsVersion = "3";
      };
    };
  };
}
