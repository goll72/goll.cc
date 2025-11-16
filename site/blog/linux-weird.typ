#import "/lib/lib.typ": *

#show: page
#show: article

#outline()

= Linux Oddities

As I've used and tinkered with Linux on various devices and in
different contexts, I've experienced my own share of "weird"
occurrences. Here I will keep a log of such occurrences, with
a few tips for debugging that sort of stuff.

== When `pacman` would hang for seemingly no reason

I often find myself in need of some rather obscure packages.
In one of those occasions, I had a laptop which wasn't very
powerful, so I decided to use my desktop as an NFS share
providing a `pacman` package repository. That worked well,
until the desktop would eventually go offline: running any
`pacman` sync command would just hang up, for seemingly no
reason. Intrigued, I ran `pacman` under `strace` to see if
I could figure out what was happening and, sure enough,
that's when it hit me:

```
# strace pacman -Syu
...
newfstatat(AT_FDCWD, "/mnt/nfs/.../pkgcache/...")
^C^C
```

The `pacman` process was stuck checking for a keyring file in
the NFS share.

#quote[
  As it turns out, if an NFS file system is unreachable, the
  kernel will wait indefinitely for it to be brought back up.
  Since the process requesting the file is blocked on I/O, you
  can only kill it by sending `SIGKILL` as `root`. How fun!
]

== `binfmt_misc` + `toybox`

One time I was setting up a RISC-V Linux VM and decided to
compile a userland for it myself (why not?), and I ended up
using `toybox` to supply core system utilities. I built a
statically-linked `toybox` using a custom-built `tcc` + `musl`
environment, and that went well. Then, I tried to install it,
using:

```
# make DESTDIR=/path/to/vm/root PREFIX=/usr install
```

Unfortunately for me, the `toybox` build system does not
honor `DESTDIR`, which meant I had just ovewritten a bunch
of important system binaries with ones that were compiled
for a different architecture! That wasn't the end, though:
I had also coincidentally set up `binfmt_misc` to run RISC-V
binaries with QEMU user-mode emulation, so that I could test
the userland stuff before "deploying" it.

The result wasn't catastrophic, but rather silent system
corruption: everything seemed normal initially, but every
binary run that messed with system files would do more and
more damage: error messages like `unrecognized flag <xyz>`
turned into my system refusing to shut down and
then entire files like `/etc/group` disappearing. At that
point, I just gave up and reinstalled everything.

#quote[
  Don't run stuff with a higher privilege level than what
  is actually needed. Although the tooling for it may be
  precarious, creating VM images doesn't have to be a
  privileged operation.
]
