# unraid-stable-ipv6

An Unraid plugin that keeps a short, predictable IPv6 address on the host when
the provider hands out a new prefix.

Settings live under **Settings -> User Utilities -> Stable IPv6**: enable,
interface, and the suffix (default `::5`). On a delegated
`2001:db8:1:2::/64` that gives `2001:db8:1:2::5`, and the address follows
automatically when the prefix changes.

Containers on the macvlan network of that interface, which is what
`Custom : eth0` in a container template means, get a suffix of their own in the
same page. Leave the template's **Fixed IP address** field empty for IPv6: an
address pinned there belongs to the subnet Docker was created with and dies with
the prefix.

## Why a plugin and not one line of config

dhcpcd 9.x, which Unraid ships, forms its SLAAC address from the MAC
(`slaac hwaddr`) and has no option for a fixed suffix. The kernel token
mechanism (`ip token`) does not help either: dhcpcd handles the router
advertisements itself and leaves `accept_ra` at 0, so the kernel never forms a
SLAAC address that a token could shape. The plugin therefore maintains a second
address and follows prefix changes through `ip -6 monitor`.

dhcpcd 10 adds `slaac token <token>`, which replaces the host half of this.
Once Unraid ships that version, a single line in `dhcpcd.conf` does that job.

Containers are the other way round: inside the namespace the kernel does do
SLAAC, so a token works there and gives a real fixed interface identifier. It
lives in the network namespace and is gone after every container start, which
is why the daemon watches `docker events`.

## Install

In the Unraid WebUI under **Plugins -> Install Plugin**, paste:

    https://raw.githubusercontent.com/Lolig4/unraid-stable-ipv6/main/stable-ipv6.plg

Or from a terminal:

    /usr/local/sbin/plugin install https://raw.githubusercontent.com/Lolig4/unraid-stable-ipv6/main/stable-ipv6.plg

It installs disabled, so nothing changes until you enable it in the WebUI.
`rc.local` reinstalls every plugin at boot, which is what starts the daemon
again, so no entry in `/boot/config/go` is needed.

## Editing

`stable-ipv6.plg` is generated. Edit the files under `files/` and run:

    ./build.sh

The `@@name@@` markers in `stable-ipv6.plg.in` are replaced with the matching
file from `files/`. The build refuses to write a plugin whose XML is broken or
whose shell scripts do not parse.
