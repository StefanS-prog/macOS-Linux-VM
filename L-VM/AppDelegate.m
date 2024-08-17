//
//  AppDelegate.m
//  L-VM
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end


@implementation AppDelegate {
    __strong IBOutlet NSWindow              *window;
    __weak IBOutlet VZVirtualMachineView    *virtualMachineView;
    
    VZVirtualMachine                        *virtualMachine;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    VZVirtualMachineConfiguration *virtualMachineConfiguration = [[VZVirtualMachineConfiguration alloc] init];
    [virtualMachineConfiguration setCPUCount:4];
    [virtualMachineConfiguration setMemorySize:(uint64_t)4 * 1024 * 1024 * 1024];
    [virtualMachineConfiguration setKeyboards:@[[[VZUSBKeyboardConfiguration alloc] init]]];
    [virtualMachineConfiguration setPointingDevices:@[[[VZUSBScreenCoordinatePointingDeviceConfiguration alloc] init]]];
   
    VZVirtioNetworkDeviceConfiguration *networkDeviceConfiguration = [[VZVirtioNetworkDeviceConfiguration alloc] init];
    [networkDeviceConfiguration setAttachment:[[VZNATNetworkDeviceAttachment alloc] init]];
    [virtualMachineConfiguration setNetworkDevices:@[networkDeviceConfiguration]];

    VZGenericPlatformConfiguration *platform = [[VZGenericPlatformConfiguration alloc] init];
    VZEFIBootLoader *bootloader = [[VZEFIBootLoader alloc] init];
    NSMutableArray *diskArray = [[NSMutableArray alloc] init];
    
    NSURL *efiURL = [NSURL fileURLWithPath:FOLDER@"/efi_store"];   // path to EFI NVRAM file
    NSURL *machineIdentifierURL = [NSURL fileURLWithPath:FOLDER@"/machine_identifier"];    // path to machine id file
    
    BOOL needsInstall;
    needsInstall = ![efiURL checkResourceIsReachableAndReturnError:nil] || ![machineIdentifierURL checkResourceIsReachableAndReturnError:nil];

    if (needsInstall) {
        [bootloader setVariableStore:[[VZEFIVariableStore alloc] initCreatingVariableStoreAtURL:efiURL options:VZEFIVariableStoreInitializationOptionAllowOverwrite error:NULL]];

        NSURL *installImageURL = [NSURL fileURLWithPath:FOLDER ISOIMAGE]; // path to ISO image
        VZDiskImageStorageDeviceAttachment *attachment = [[VZDiskImageStorageDeviceAttachment alloc] initWithURL:installImageURL readOnly:YES error:nil];
        VZUSBMassStorageDeviceConfiguration *usbDeviceConfiguration = [[VZUSBMassStorageDeviceConfiguration alloc] initWithAttachment:attachment];
        [diskArray addObject:usbDeviceConfiguration];
        
        VZGenericMachineIdentifier *machineIdentifier = [[VZGenericMachineIdentifier alloc] init];
        [[machineIdentifier dataRepresentation] writeToURL:machineIdentifierURL atomically:YES];
        [platform setMachineIdentifier:machineIdentifier];
    } else {
        [bootloader setVariableStore:[[VZEFIVariableStore alloc] initWithURL:efiURL]];
        
        NSData *machineRepresentation = [[NSData alloc] initWithContentsOfURL:machineIdentifierURL];
        VZGenericMachineIdentifier *machineIdentifier = [[VZGenericMachineIdentifier alloc] initWithDataRepresentation:machineRepresentation];
        [platform setMachineIdentifier:machineIdentifier];
    }
    
    [virtualMachineConfiguration setBootLoader:bootloader];
    [virtualMachineConfiguration setPlatform:platform];
    
    NSError *error;
   
    // The disk image cannot have any size. 16 GB, 32 GB, and 64 GB have been tested and work.
    NSURL *mainDiskImageURL = [NSURL fileURLWithPath:FOLDER@"/disk_image"];    // path to disk image
    VZDiskImageStorageDeviceAttachment *mainDiskAttachment = [[VZDiskImageStorageDeviceAttachment alloc] initWithURL:mainDiskImageURL readOnly:NO error:&error];
    NSLog(@"StorageDeviceAttachment with error: %@", [error localizedDescription]);
    VZVirtioBlockDeviceConfiguration *mainDiskConfiguration = [[VZVirtioBlockDeviceConfiguration alloc] initWithAttachment:mainDiskAttachment];
    
    [diskArray addObject:mainDiskConfiguration];
    [virtualMachineConfiguration setStorageDevices:diskArray];
    
    VZVirtioGraphicsDeviceConfiguration *graphicsConfiguration = [[VZVirtioGraphicsDeviceConfiguration alloc] init];
    [graphicsConfiguration setScanouts:@[[[VZVirtioGraphicsScanoutConfiguration alloc] initWithWidthInPixels:1920 heightInPixels:1200]]];
    [virtualMachineConfiguration setGraphicsDevices:@[graphicsConfiguration]];
    
    VZVirtioSoundDeviceOutputStreamConfiguration *outputStream = [[VZVirtioSoundDeviceOutputStreamConfiguration alloc] init];
    [outputStream setSink:[[VZHostAudioOutputStreamSink alloc] init]];
    VZVirtioSoundDeviceConfiguration *outputSoundDeviceConfiguration = [[VZVirtioSoundDeviceConfiguration alloc] init];
    [outputSoundDeviceConfiguration setStreams:@[outputStream]];
    [virtualMachineConfiguration setAudioDevices:@[outputSoundDeviceConfiguration]];
    
    [virtualMachineConfiguration validateWithError:&error];
    NSLog(@"Validation with error: %@", [error localizedDescription]);
    
    virtualMachine = [[VZVirtualMachine alloc] initWithConfiguration:virtualMachineConfiguration];
    [virtualMachine setDelegate:self];
    
    [virtualMachineView setVirtualMachine:virtualMachine];
    [virtualMachineView setAutomaticallyReconfiguresDisplay:YES];

    [self startVM:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (void)guestDidStopVirtualMachine:(VZVirtualMachine *)virtualMachine {
    NSLog(@"Guest has stopped virtual machine");
    [NSApp terminate:self];
}

- (void)virtualMachine:(VZVirtualMachine *)virtualMachine didStopWithError:(NSError *)error {
    NSLog(@"Virtual machine has stopped with error: %@", [error localizedDescription]);
    exit(EXIT_FAILURE);
}

- (void)virtualMachine:(VZVirtualMachine *)virtualMachine networkDevice:(VZNetworkDevice *)networkDevice attachmentWasDisconnectedWithError:(NSError *)error {
    NSLog(@"Network attachment was disconnected with error: %@", [error localizedDescription]);
    exit(EXIT_FAILURE);
}

- (IBAction)stopGuest:sender {
    [virtualMachine requestStopWithError:nil];
}

- (IBAction)stopVM:sender {
    [virtualMachine stopWithCompletionHandler:^(NSError *error) {
        NSLog(@"Stop attempt with error: %@", [error localizedDescription]);
    }];
}

- (IBAction)startVM:sender {
    [virtualMachine startWithCompletionHandler:^(NSError *error) {
        NSLog(@"Start attempt with error: %@", [error localizedDescription]);
    }];
}

- (IBAction)pauseVM:sender {
    [virtualMachine pauseWithCompletionHandler:^(NSError *error) {
        NSLog(@"Pause attempt with error: %@", [error localizedDescription]);
    }];
}

- (IBAction)resumeVM:sender {
    [virtualMachine resumeWithCompletionHandler:^(NSError *error) {
        NSLog(@"Resume attempt with error: %@", [error localizedDescription]);
    }];
}
    
- (IBAction)saveVM:sender {
    NSURL *vmStateURL = [NSURL fileURLWithPath:FOLDER@"/vm_state"];
    [virtualMachine saveMachineStateToURL:vmStateURL completionHandler:^(NSError *error) {
        NSLog(@"Save attempt with error: %@", [error localizedDescription]);
    }];
}

- (IBAction)restoreVM:sender {
    NSURL *vmStateURL = [NSURL fileURLWithPath:FOLDER@"/vm_state"];
    [virtualMachine restoreMachineStateFromURL:vmStateURL completionHandler:^(NSError *error) {
        NSLog(@"Restore attempt with error: %@", [error localizedDescription]);
    }];
}

@end
