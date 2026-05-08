{ ... }:
{
  services = {
    flatpak = {
      enable = true;

      packages = [
        "com.github.tchx84.Flatseal" # Manage flatpak permissions - should always have this
        "io.github.flattool.Warehouse" # Manage flatpaks, clean data, remove flatpaks and deps
        "hu.irl.cameractrls" # Camera management
        "com.bambulab.BambuStudio" # Bambu Studio
      ];

      update.onActivation = true;
    };
  };
}
