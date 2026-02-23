{ pkgs, ... }:
{

  services.snapper = {
    snapshotInterval = "daily";
    cleanupInterval = "1d";
    configs.root = {
      SUBVOLUME = "/";
      ALLOW_GROUPS = [ "wheel" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 0;
      TIMELINE_LIMIT_DAILY = 30;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

}
