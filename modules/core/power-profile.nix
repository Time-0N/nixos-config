{ ... }:
{
  # The two daemons the bar's laptop-mode islands read. Neither is a display
  # concern — both are what actually reports and applies, and the bar only ever
  # draws what they say.

  # Kept after the waybar module was removed, which was the original reason it
  # was switched on. The bar now has the widget waybar had: qml/bar/power/
  # switches profiles through it, and asks it what profiles this machine offers
  # before showing the control at all.
  services.power-profiles-daemon.enable = true;

  # The battery readout's only source. Without this, `UPower.displayDevice`
  # exists but reports nothing — quickshell logs "Could not launch service
  # org.freedesktop.UPower: the name is not activatable" and the island stays
  # hidden, which is correct behaviour for a machine with no battery and
  # useless behaviour for a laptop.
  #
  # It is enabled on every host rather than on the laptop only: it costs a
  # dbus-activated daemon that a desktop never starts, and gating it per host
  # would mean a machine that grows a battery also needing a config change to
  # notice.
  services.upower.enable = true;
}
