{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.wootility ];
  services.udev.extraRules = ''
    # Wooting (generic — covers 60HE, 60HE+, 80HE, Two HE, UwU, etc.)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", MODE:="0660", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="usb",    ATTRS{idVendor}=="31e3", MODE:="0660", GROUP="input", TAG+="uaccess"
  '';
}
