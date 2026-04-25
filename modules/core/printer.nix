{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      # hplip        # HP
      # cnijfilter2  # Canon
      # epson-escpr  # Epson
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true; # Needed for mDNS printer discovery
  };

  environment.systemPackages = with pkgs; [
    system-config-printer
  ];
}
