//
//  AppDelegate.h
//  L-VM
//

#import <Cocoa/Cocoa.h>
#import <Virtualization/Virtualization.h>

#define FOLDER      @"/Users/stefan/Documents"
#define SHARED      @"shared-with-VM"
#define ISOIMAGE    @"AlmaLinux-10.2-aarch64-dvd.iso"

@interface AppDelegate : NSObject <NSApplicationDelegate, VZVirtualMachineDelegate>

- (IBAction)stopGuest:sender;
- (IBAction)startVM:sender;
- (IBAction)pauseVM:sender;
- (IBAction)resumeVM:sender;
- (IBAction)saveVM:sender;
- (IBAction)restoreVM:sender;
- (IBAction)showAppInfo:sender;

@end
