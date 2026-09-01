{ ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."92-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [
          44100
          48000
        ];
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 2048;
      };
    };

    extraConfig.pipewire-pulse."92-latency" = {
      "pulse.properties" = {
        "pulse.min.req" = "128/48000";
        "pulse.default.req" = "512/48000";
        "pulse.max.req" = "2048/48000";
        "pulse.min.quantum" = "128/48000";
        "pulse.max.quantum" = "2048/48000";
      };
    };
  };

  security.rtkit.enable = true;
}
