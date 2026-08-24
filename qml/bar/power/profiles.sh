#!/usr/bin/env bash
# Which power profiles power-profiles-daemon offers, as a JSON array in the
# daemon's own order:
#
#   ["power-saver","balanced","performance"]
#
# Quickshell's PowerProfiles service can say which profile is *active* and
# whether a performance profile exists, but has no property for whether the
# daemon is there at all — with ppd stopped it simply reports the default,
# Balanced, which is indistinguishable from a machine sitting in Balanced. So
# the bar asks here before offering a control that would otherwise write into
# nothing. See ../settings/displays/vrrcap.sh, which exists for the same
# reason on the other side of the panel.
#
# The list is also the answer to "which modes does this machine have". Not
# every laptop has all three: the performance profile depends on the platform
# driver, and ppd simply leaves it out when there is none.
#
# An empty array means no daemon. That is reported as *unavailable* rather than
# as an error, because a desktop without ppd is not a fault — it is the normal
# case for the machine this bar is mostly used on.
set -uo pipefail

# busctl comes from systemd, which is already a runtime input for the shell,
# so this needs nothing that was not already there. The name is the one ppd
# takes over from UPower; it also owns net.hadess.PowerProfiles, but that one
# is the legacy alias.
profiles=$(
  busctl --system --json=short get-property \
    org.freedesktop.UPower.PowerProfiles \
    /org/freedesktop/UPower/PowerProfiles \
    org.freedesktop.UPower.PowerProfiles \
    Profiles 2>/dev/null
) || {
  echo '[]'
  exit 0
}

# Each entry is a dict of variants — Profile, CpuDriver, Driver — and only the
# name is wanted. `// empty` rather than a default, so a malformed entry drops
# out of the list instead of landing in it as null.
printf '%s' "$profiles" | jq -c '[.data[]?.Profile.data // empty]' 2>/dev/null || echo '[]'
