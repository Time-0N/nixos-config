{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.yarg ];

  # Give the logged-in user access to HID devices (guitars, drums etc.)
  # Has to be a package with a number below 73, otherwise "uaccess" doesn't work
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "yarg-hid-udev-rules";
      text = ''
        KERNEL=="hidraw*", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/69-hid.rules";
    })
  ];

  # Fallback if the rule above doesn't work for you:
  # remove the "#" in the 3 lines below (gives everyone access to HID devices)
  # services.udev.extraRules = ''
  #   KERNEL=="hidraw*", MODE="0666"
  # '';
}
