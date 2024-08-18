Linux-based Virtual Machine using Apple Virtualization
======================================================
This project demonstrates a minimal Linux-based VM using Apple’s virtualization framework. It provides a menu to change the VM’s state.

Tests have shown that the restore feature only works as long as the application is running.

Setup
-----
1. Open the Xcode project file.
2. Change in the file `AppDelegate.h` the `FOLDER` macro to the path used to create the VM’s files and load the ISO image.
3. Change in the file `AppDelegate.h` the `ISOIMAGE` macro to the ISO image file name.
4. Create in the folder you have chosen a disk image file with the name `disk_image`. You can create eg. a 16 GiB disk image by typing `dd if=/dev/zero of=disk_image bs=1 count=1 seek=17179869183` in the folder. Verified file sizes are 16 GiB, 32 GiB, and 64 GiB. Arbitrary file sizes do not work.
5. Select the menu item `Product > Run` to start the application.
