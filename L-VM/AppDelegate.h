//
//  AppDelegate.h
//  L-VM
//

#import <Cocoa/Cocoa.h>
#import <Virtualization/Virtualization.h>

#define FOLDER      @"/Users/stefan/Documents"
#define ISOIMAGE    @"ubuntu-24.04-live-server-arm64.iso"

@interface AppDelegate : NSObject <NSApplicationDelegate, VZVirtualMachineDelegate>

- (IBAction)stopGuest:sender;
- (IBAction)startVM:sender;
- (IBAction)pauseVM:sender;
- (IBAction)resumeVM:sender;
- (IBAction)saveVM:sender;
- (IBAction)restoreVM:sender;

@end
