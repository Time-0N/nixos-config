{ ... }:

{
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;

  security.polkit.enable = true;

  environment.pathsToLink = [ "/share/thumbnailers" ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
           action.id == "org.freedesktop.udisks2.filesystem-mount-system") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
