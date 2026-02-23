{
  lib,
  pkgs,
  ...
}:
let
  quotes = import ./quotes.nix;

  quotesFile = pkgs.writeText "aperture-quotes.txt" (lib.concatStringsSep "\n" quotes);

  aperture-fetch = pkgs.writeShellApplication {
    name = "fastfetch";

    runtimeInputs = with pkgs; [
      fastfetch
      coreutils
      gnused
    ];

    text = ''
      # 1. Fetch system info invisibly (stripping colors so we can measure text length)
      info_raw=$(fastfetch --logo none --pipe | sed -r 's/\x1b\[[0-9;]*[a-zA-Z]//g' | expand)
      mapfile -t sys_info <<< "$info_raw"

      # 2. Grab a random quote and wrap it to fit the box (max 42 chars wide)
      quote=$(shuf -n 1 ${quotesFile})
      mapfile -t quote_lines < <(echo "$quote" | fold -s -w 42)

      # 3. The exact Aperture Science Logo
      mapfile -t logo_lines << 'LOGO'
                    .,-:;//;:=,
                . :H@@@MM@M#H/.,+%;,
             ,/X+ +M@@M@MM%=,-%HMMM@X/,
           -+@MM; $M@@MH+-,;XMMMM@MMMM@+-
          ;@M@@M- XM@X;. -+XXXXXHHH@M@M#@/.
        ,%MM@@MH ,@%=             .---=-=:=,.
        =@#@@@MX.,                -%HX$$%%%+;
       =-./@M@M$                   .;@MMMM@MM:
       X@/ -$MM/                    . +MM@@@M$
      ,@M@H: :@:                    . =X#@@@@-
      ,@@@MMX, .                    /H- ;@M@M=
      .H@@@@M@+,                    %MM+..%#$.
       /MMMM@MMH/.                  XM@MH; =;
        /%+%$XHH@$=              , .H@@@@MX,
         .=--------.           -%H.,@@@@@MX,
         .%MM@@@HHHXX$$$%+- .:$MMX =M@@MM%.
           =XMMM@MM@MM#H;,-+HMM@M+ /MMMX=
             =%@M@M#@$-.=$@MM@@@M; %M%=
               ,:+$+-,/H#MMMMMMM@= =,
                     =++%%%%+/:-.
      LOGO

      ORANGE='\033[38;5;214m'
      NC='\033[0m'

      echo -e "''${ORANGE}---------------------------------------------------------------------------------------------------''${NC}"

      for i in {0..26}; do
          if [ "$i" -eq 0 ]; then
              left="Forms FORM-29827281-12:"
          elif [ "$i" -eq 1 ]; then
              left="Fetch Assessment Report"
          elif [ "$i" -eq 2 ]; then
              left=""
          elif [ "$i" -ge 3 ] && [ $((i-3)) -lt ''${#sys_info[@]} ]; then
              left="''${sys_info[$((i-3))]}"
          else
              left=""
          fi

          left="''${left:0:46}"
          printf -v left_padded "%-46s" "$left"

          if [ "$i" -lt 5 ]; then
              if [ "$i" -lt "''${#quote_lines[@]}" ]; then
                  right="''${quote_lines[$i]}"
              else
                  right=""
              fi
          elif [ "$i" -eq 5 ]; then
              right="------------------------------------------------"
          else
              logo_idx=$((i-6))
              if [ "$logo_idx" -lt "''${#logo_lines[@]}" ]; then
                  right="''${logo_lines[$logo_idx]}"
              else
                  right=""
              fi
          fi

          right="''${right:0:48}"
          if [ "$i" -eq 5 ]; then
              printf -v right_padded "%-48s" "$right"
              echo -e "''${ORANGE}| ''${left_padded} |''${right_padded}|''${NC}"
          else
              printf -v right_padded "%-46s" "$right"
              echo -e "''${ORANGE}| ''${left_padded} | ''${right_padded} |''${NC}"
          fi
      done

      echo -e "''${ORANGE}---------------------------------------------------------------------------------------------------''${NC}"
    '';
  };
in
{
  programs.fastfetch = {
    enable = true;
    package = aperture-fetch;

    settings = {
      logo = {
        type = "none";
      };
      display = {
        separator = ": ";
        pipe = true;
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "localip"
        "battery"
        "locale"
      ];
    };
  };

}
