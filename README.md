# very simple Arch Linux setup

This is just a simple setup script to bootstrap Arch

Use at own risk!
It's not tested properly etc...

(It's mostly to document my own setup)

*NOTE*: It's currently only able to take care of a single encrypted disk.
So, everything except /boot in a flat partition

# Usage
* Clone repo
* You probably need to partition your disk for your needs
* Fill out missing values with whatever you want/need
* Check if `package-list.txt` contains what you want. Edit if needed.
* run script:
```bash
./arch-setup.sh
```
* Hopefully be happy. If not, blame the lizard people.

# Still missing
* partitioning
* network setup (wpa enterprise)
* timezone config
* daemon config for:
    * network-manager
    * ntp
* thunderbolt dock config
* optional user specific configs(?)
