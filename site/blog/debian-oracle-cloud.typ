#import "/lib/lib.typ": *

#show: page
#show: article

= Debian on Oracle Cloud Free Tier

Oracle Cloud has an always-free tier, which allows you to create
one ARM64 instance with 24GB of RAM and 4 cores, as well as 2
x86_64 instances (VM.Standard.E2.1.Micro) with 1GB of RAM and 2
cores. While setting up the instances, you can choose an OS image
to bootstrap them with, but if you're on the free tier you can't
bring your own images. While many options are available from the
marketplace, Debian is, unfortunately, not one of them.

But I really wanted to use Debian on the "Micro" instance. So I
installed it over the distro that I had to choose when creating
the instance, and here I've documented the process.

#quote[
  === What about kexec?

  For some distros, such as NixOS, there is preexisting tooling
  to install it over an existing distro using kexec. However, that
  wouldn't help me in this case, since:

   + I want Debian
   + I also tried to use kexec to bootstrap Debian, but it
     always hung up after `kexec_core: starting new kernel`,
     so eventually I gave up.
]

== Considerations

1GB of RAM is, admittedly, not a lot, so I wouldn't be able to install Debian
over the distro I had chosen when creating the instance the conventional way.

So my plan was:

  - Boot into a minimal kernel and initramfs environment
  - Download a custom-built Debian disk image and write it to disk
    as it is being downloaded
  - Reboot and pray that it works
  - Grow the `/` partition to use the whole disk

== Creating the initial boot environment

First, I got `busybox` and installed it, alongside a minimal `init`
script that would load the kernel modules present in the initramfs:

```sh
mkdir initramfs-root
cd initramfs-root

mkdir proc sys dev

for i in $(busybox --list-full); do
    mkdir -p "$(dirname "$i")"
    cd "$(dirname "$i")"
    ln -s /busybox "$(basename "$i")"
    cd -
done

cp $(which busybox) .

cat <<EOF > init
#!/bin/sh

export PATH=/bin:/usr/bin:/sbin:/usr/sbin

mount -t devtmpfs devtmpfs /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys

for i in /modules/*.ko; do
    insmod "$i" && rm "$i"
done

exec setsid -c /bin/sh
EOF
```

Then, I got the kernel image from the `linux-image` Debian
package, that can be downloaded from `packages.debian.org`.

```sh
mkdir linux-image-amd64
cd linux-image-amd64

ar x .../linux-image-*.deb
tar xf data.tar.xz

cp boot/vmlinuz-* ../vmlinuz

cd ..
```

After doing that, I still needed to have working network
drivers, so I checked the driver being used on the instance
using `lsmod`, and then copied the relevant kernel module
files over to the initramfs, enumerating them in the order
they should be loaded to make my life easier (The proper
way to set this up would be to use `depmod`, but that would
increase the initramfs size and I couldn't be bothered with it).

Thankfully, the instance uses a virtio-net NIC, so I didn't
have to worry about any proprietary firmware blobs.

Eventually, I realized that I would also need working drivers
for the main disk, which in this case was virtio-scsi + the
sd (SCSI disk) kitchen-sink device driver.

```sh
ls initramfs-root/modules
```

```
00-failover.ko     01-net_failover.ko  02-sd_mod.ko      02-virtio_scsi.ko
00-scsi_common.ko  01-scsi_mod.ko      02-virtio_net.ko
```

Then, I could generate the initramfs and copy it to the instance:

```sh
find . -print0 | cpio --null --create --verbose --format=newc > ../initrd.img

scp initrd.img vmlinuz ...
```

But how would I boot from that kernel if kexec didn't work? Well,
thankfully, the distro installed on the instance at that point
used GRUB as its bootloader, so I was able to move the two files
to a partition accessible from GRUB and boot the kernel from there,
thanks to Oracle Cloud's "Cloud Shell", which allows accessing the
instance from the cloud dashboard by means of a serial connection.

Though, first, I had to figure out a way to make the GRUB menu
show up at all, but that was simple enough:

```sh
cat <<EOF >>/etc/default/grub
GRUB_TIMEOUT=5
GRUB_TERMINAL="console serial"
EOF

grub2-mkconfig -o /boot/grub2/grub.cfg
```

Then, from the GRUB console, I was able to load the kernel and the initrd:

```
ls
linux (hdX,Y)/vmlinuz console=ttyS0
initrd (hdX,Y)/initrd.img
boot
```

After getting into a shell, I tried to set up the interface using DHCP:

```sh
ip link set eth0 up
udhcpc
udhcpc6
```

To my dismay, `udhcpc` didn't work. Even after trying to add a route,
nothing worked. Neither IPv4 or IPv6. So I decided to use `dhcpcd`
instead, using good old `zig cc` to get a statically-linked binary:

```sh
curl -L -O ... # dhcpcd release tarball

tar xf dhcpcd*.tar.xz
cd dhcpcd*

CC="zig cc -static" ./configure --without-udev
make -j $(nproc)

make DESTDIR=.../initramfs-root install
rm -r .../initramfs-root/usr/share/man
```

After regenerating the initramfs and rebooting, I was greeted with:

```sh
ip link set eth0 up
dhcpcd -d eth0
ping -c 3 1.1.1.1
ping6 -c 3 2600::
```

```
...

PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: seq=0 ttl=60 time=1.230 ms
64 bytes from 1.1.1.1: seq=1 ttl=60 time=1.209 ms
64 bytes from 1.1.1.1: seq=2 ttl=60 time=1.217 ms

--- 1.1.1.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 1.209/1.218/1.230 ms

PING 2600:: (2600::): 56 data bytes
64 bytes from 2600::: seq=0 ttl=55 time=115.404 ms
64 bytes from 2600::: seq=1 ttl=55 time=115.339 ms
64 bytes from 2600::: seq=2 ttl=55 time=115.304 ms

--- 2600:: ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 115.304/115.349/115.404 ms
```

Finally, we are connected to the internet!

== Writing the disk image

First, I allocated a disk image using `dd` (you could also
use `fallocate` to avoid writing a bunch of zeros to disk)

```sh
dd if=/dev/zero of=disk.img bs=1M count=$((5 * 1024))

# Partition table setup using fdisk
# (VM.Standard.E2.1.Micro instances use BIOS)
...

fdisk -l disk.img
```

```
Disk disk.img: 5 GiB, 5368709120 bytes, 10485760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

Device       Start      End Sectors  Size Type
disk.img1     2048     4095    2048    1M BIOS boot
disk.img2     4096  1052671 1048576  512M Linux extended boot
disk.img3  1052672 10483711 9431040  4.5G Linux root (x86-64)
```

On BIOS systems, a 1MB BIOS boot partition is needed when using
the GPT partitioning scheme so that GRUB can stuff its
initialization code there (on MBR, you just need to leave a 1MB gap
before the first partition). The extended boot partition houses
`/boot` (using ext4 or similar) so that the `/` partition can use
more "exotic" filesystems that aren't well supported by GRUB, such
as btrfs and ZFS.

But how do we mount the partitions to actually work on them? That's
where loop devices come in: loop devices are block devices backed by
a regular file, rather than an actual storage device. Two
common tools to create loop devices are `losetup` and `kpartx`.
It doesn't really matter which one you pick, but I prefer `kpartx`.

```sh
kpartx -a disk.img
lsblk
```

```
...
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0         7:0    0     5G  0 loop
├─loop0p1   253:1    0     1M  0 part
├─loop0p2   253:2    0   512M  0 part
└─loop0p3   253:3    0   4.5G  0 part
```

Then, I formatted the partitions and strapped it with Debian Trixie, like so:

```sh
mkfs.ext4 /dev/mapper/loop0p2
mkfs.btrfs -K /dev/mapper/loop0p3

mount /dev/mapper/loop0p3 -o compress=zstd rootfs
mkdir rootfs/boot
mount /dev/mapper/loop0p2 rootfs/boot

debootstrap --include=linux-image-amd64,openssh-server,dhcpcd,btrfs-progs,zstd,bsdextrautils,man,sudo trixie rootfs
```

Next, I prepared the virtual filesystems and bind mounts needed to chroot into the rootfs:

```sh
mount -t proc proc rootfs/proc

mount --rbind /sys rootfs/sys
mount --make-rslave rootfs/sys

mount --rbind /dev rootfs/dev
mount --make-rslave rootfs/dev

mount -t tmpfs tmpfs rootfs/tmp
mount -t tmpfs tmpfs rootfs/run

mount --bind /etc/resolv.conf rootfs/etc/resolv.conf

chroot rootfs
```

#quote[
  === Why the bind mount for `/etc/resolv.conf`?

  While not needed _per se_, the bind mount allows programs running in the chroot
  environment to see the same `resolv.conf` as programs running on the host outside of
  the chroot. But unlike a simple copy, it ensures that when the filesystem is unmounted,
  the regular `resolv.conf` that was there will be unaltered.
]

```sh
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

systemctl enable dhdpcd ssh

useradd goll -U -d /home/goll -m
mkdir -p /home/goll/.ssh

echo "..." >> /home/goll/.ssh/authorized_keys

apt update
apt install grub-pc

sed -i 's/GRUB_TERMINAL=console/GRUB_TERMINAL="console serial"/' /etc/default/grub

cat <<EOF >>/etc/fstab
PARTUUID=$(blkid | sed -n 's#^/dev/mapper/loop0p2:.*PARTUUID="\(.*\)".*$#\1#p')    /boot    ext4    rw,nofail             0    0
PARTUUID=$(blkid | sed -n 's#^/dev/mapper/loop0p3:.*PARTUUID="\(.*\)".*$#\1#p')    /        btrfs   rw,compress=zstd      0    0
EOF

update-grub
grub-install /dev/loop0
dpkg-reconfigure initramfs-tools
```

#quote[
  The scripts provided by Debian got a bit confused when faced with
  loop devices, so I had to run `grub-install /dev/loop0` manually to
  ensure GRUB would write its initialization code onto the BIOS boot partition.
]

== Transferring the image over the network

While there's more setup to be done, it can be done on the live system, over a serial connection,
after the image has been written. So how do we write it to disk? We can't keep the whole image
in RAM (while it might have been possible if I had used a smaller size for the image, it would
still be a bit risky), so why not use pipelines to write the data as we receive it?

First, I ran `sha512sum` on the image and saved its checksum. Then, I used an HTTP
server on one machine that had the disk image and busybox's `wget` on the instance to
download the image, write it to disk and calculate its checksum at the same time:

```sh
mkfifo fifo
sha512sum < fifo > checksum &
wget -O - http://.../disk.img | tee fifo > /dev/sda
```

At last, I rebooted, and was greeted to GRUB once again, but this time showing
`Debian GNU/Linux` as the main (and only) boot option. Then I realized I forgot
to set a user password so I had to add `init=/bin/sh` to the kernel command line
via GRUB's editor.

== Resizing the partition

This is, to me, the most dreadful part of this whole ordeal. I've always been
scared to mess with partitions, especially in a live system, but perhaps my fear
was undeserved.

First, we have to move the backup GPT header to the end of the disk, using
`sgdisk -e /dev/sda`. Then, we have to delete and re-create the root partition,
also using `sgdisk` (this doesn't overwrite any data in the root partition itself),
then tell the kernel to reload the partition table using `partprobe` or `kpartx`.
After that, all we have to do (if using btrfs) is run `btrfs filesystem resize max /`,
to make it use the available space.
