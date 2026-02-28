{ pkgs }:

pkgs.writeShellApplication {
  name = "waybar-os-logo";
  runtimeInputs = [ ];
  text = ''
    set -euo pipefail
    # shellcheck disable=SC1091
    . /etc/os-release 2>/dev/null || { ID="linux"; PRETTY_NAME="Linux"; }
    kernel="$(uname -r)"

    case "$ID" in
      arch)                icon=""; class="os-arch"       ;;
      ubuntu)              icon=""; class="os-ubuntu"     ;;
      debian)              icon=""; class="os-debian"     ;;
      fedora)              icon=""; class="os-fedora"     ;;
      nixos)               icon=""; class="os-nixos"      ;;
      opensuse*|suse|sles) icon=""; class="os-opensuse"  ;;
      manjaro)             icon=""; class="os-manjaro"    ;;
      gentoo)              icon=""; class="os-gentoo"     ;;
      void)                icon=""; class="os-void"       ;;
      pop|pop-os|pop_os)   icon=""; class="os-pop_os"    ;;
      elementary)          icon=""; class="os-elementary" ;;
      *)                   icon=""; class="os-linux"      ;;
    esac

    printf '{"text":"%s","tooltip":"%s • %s","class":"%s"}\n' \
      "$icon" "''${PRETTY_NAME:-Linux}" "$kernel" "$class"
  '';
}
