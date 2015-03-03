#
# AppArmor confinement for docker daemon
#
# This confinement is intentionally not restrictive and is here to help guard
# against programming errors and not for security confinement. docker daemon
# requires far too much access to effictively confine and by its very nature it
# must be considered a trusted service.
#

#include <tunables/global>

# Specified profile variables
###VAR###

###PROFILEATTACH### (attach_disconnected) {
  #include <abstractions/base>
  #include <abstractions/consoles>
  #include <abstractions/dbus-strict>
  #include <abstractions/nameservice>
  #include <abstractions/openssl>
  #include <abstractions/ssl_certs>

  # FIXME: app upgrades don't perform migration yet. When they do, remove
  # these two rules and see Google for further instructions.
  # See: https://app.asana.com/0/21120773903349/21160815722783
  /var/lib/apps/@{APP_PKGNAME}/   w,
  /var/lib/apps/@{APP_PKGNAME}/** wl,

  # Read-only for the install directory
  @{CLICK_DIR}/@{APP_PKGNAME}/                   r,
  @{CLICK_DIR}/@{APP_PKGNAME}/@{APP_VERSION}/    r,
  @{CLICK_DIR}/@{APP_PKGNAME}/@{APP_VERSION}/**  mrklix,

  # Writable home area
  owner @{HOMEDIRS}/apps/@{APP_PKGNAME}/   rw,
  owner @{HOMEDIRS}/apps/@{APP_PKGNAME}/** mrwklix,

  # Read-only system area for other versions
  /var/lib/apps/@{APP_PKGNAME}/   r,
  /var/lib/apps/@{APP_PKGNAME}/** mrkix,

  # TODO: the write on  /var/lib/apps/@{APP_PKGNAME}/ is needed in case it
  # doesn't exist, but means an app could adjust inode data and affect
  # rollbacks.
  /var/lib/apps/@{APP_PKGNAME}/                  w,

  # Writable system area only for this version.
  /var/lib/apps/@{APP_PKGNAME}/@{APP_VERSION}/   w,
  /var/lib/apps/@{APP_PKGNAME}/@{APP_VERSION}/** wl,

  # Allow our pid file and socket
  /run/@{APP_PKGNAME}.pid rw,
  /run/@{APP_PKGNAME}.sock rw,

  # Wide read access to /proc, but somewhat limited writes for now
  @{PROC}/** r,
  @{PROC}/[0-9]*/attr/exec w,
  @{PROC}/sys/net/** w,

  # Wide read access to /sys
  /sys/** r,
  # Limit cgroup writes a bit
  /sys/fs/cgroup/*/docker/   rw,
  /sys/fs/cgroup/*/docker/** rw,
  /sys/fs/cgroup/*/system.slice/   rw,
  /sys/fs/cgroup/*/system.slice/** rw,

  # We can trace ourselves
  ptrace (trace) peer=@{profile_name},

  # Allow execute of anything we need
  /{,usr/}bin/* pux,
  /{,usr/}sbin/* pux,

  # for console access
  /dev/ptmx rw,

  network inet stream,
  network inet6 stream,

  /dev/snd/* rw,

  # Wide access, but simpler for now for snappy specialities like 
  # the symlink /etc/timezone -> /etc/writable/timezone
  /etc/** r,
  /etc/.java/ rw,
  /etc/.java/deployment/ rw,

  /proc/*/cmdline r,
  /proc/*/coredump_filter rw,
  /proc/[0-9]*/fd/ r,
  /proc/asound/version r,
  /proc/filesystems r,

  /run/resolvconf/resolv.conf r,
  /run/shm/ r,
  /run/shm/* rw,

  /sys/devices/system/cpu/ r,
  /sys/devices/system/cpu/** r,

  /tmp/ rw,
  owner /tmp/** m,

  /usr/bin/env ix,

  /usr/local/share/fonts/ r,
  /usr/share/alsa/** r,
  /usr/share/fonts/ r,
  /usr/share/fonts/** r,
  /usr/share/glib-*/schemas/* r,
  /usr/share/icons/** r,
  /usr/share/themes/** r,
  
  /var/cache/fontconfig/* r,
  /var/lib/dbus/machine-id r,
  /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType/ r,
  /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType/* r,
  
  @{PROC}/[0-9]*/net/if_inet6 r,
  @{PROC}/[0-9]*/net/ipv6_route r,
  
  # Bug: Yes, the trailing comma is a must have:
  @{PROC}/loadavg r,

}
