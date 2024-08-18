Linux-based Virtual Machine using Apple Virtualization
======================================================
This project demonstrates a minimal Linux-based VM using Apple’s virtualization framework. It provides a menu to change the VM’s state.

Tests have shown that the restore feature only works as long as the application is running.

Setup
-----
1. Open the Xcode project file.
2. Change in the file `AppDelegate.h` the `FOLDER` macro to the path used to create the VM’s files and load the ISO image.
3. Change in the file `AppDelegate.h` the `ISOIMAGE` macro to the images’ file name.
4. Select the menu item `Product > Run` to start the application.
