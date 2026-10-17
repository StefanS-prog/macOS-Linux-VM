Linux-based Virtual Machine using Apple Virtualization
======================================================
This project demonstrates a minimal Linux-based VM using Apple’s virtualization framework. It provides a menu to change the VM’s state.

Tests have shown that the restore feature only works as long as the application is running.

Setup
-----
1. Open the Xcode project file.
2. Change in the file `AppDelegate.h` the `FOLDER` macro to the directory path used to create the VM’s files and to load the ISO image.
3. Change in the file `AppDelegate.h` the `ISOIMAGE` macro to the ISO image file name.
4. Change in the file `AppDelegate.h` the `SHARED` macro to the name of the directory you can share with the VM's Linux-based operating system.
5. Create in the folder you have chosen a disk image file with the name `disk_image`. You can create eg. a 16 GiB disk image by typing `dd if=/dev/zero of=disk_image bs=1 count=1 seek=17179869183` after changing into the folder. Verified file sizes are 16 GiB, 32 GiB, and 64 GiB. Arbitrary file sizes do not work.
6. Select the menu item `Product > Run` to start the application.
7. To use the shared directory in the Linux-based operating system you must mount it there. You can use `sudo mount -t virtiofs <SHARED macro value> <shared directory in Linux distribution>`.
8. To enable Rosetta, create a directory to mount on with `sudo mkdir /rosetta`. If you use AlmaLinux or RHEL you can create the file `/etc/binfmt.d/rosetta.conf` with the one line `:rosetta:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00:\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/rosetta/rosetta:OCF`. Make Rosetta available with `sudo mount -t virtiofs -o context=system_u:object_r:bin_t:s0 RosettaTag /rosetta`, followed by `sudo systemctl restart systemd-binfmt.service`. To make it persistent, add the line `RosettaTag /rosetta virtiofs defaults,context=system_u:object_r:bin_t:s0 0 0` to `/etc/fstab`.
