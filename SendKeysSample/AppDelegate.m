//
//  AppDelegate.m
//  SendKeysSample
//
//  Created by Hiroaki Nakamura on 2013/07/29.
//
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [[[NSWorkspace sharedWorkspace] notificationCenter]
    addObserver:self
    selector:@selector(appDidDeactivate:)
    name:NSWorkspaceDidDeactivateApplicationNotification
    object:nil];
  [[[NSWorkspace sharedWorkspace] notificationCenter]
    addObserver:self
    selector:@selector(appDidActivate:)
    name:NSWorkspaceDidActivateApplicationNotification
    object:nil];
}

- (IBAction)sendKeys:(id)sender {
  NSLog(@"sendKeys start");
  if (self.targetApplication) {
    NSLog(@"exiting because already working");
  }

  if (self.lastDeactivatedApplication == nil) {
    NSLog(@"lastDeactivatedApplication was null. exiting.");
    return;
  }
  self.targetApplication = self.lastDeactivatedApplication;
  if ([self.targetApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps] == NO) {
    NSLog(@"activate app failed. exiting.");
    return;
  }

  NSLog(@"sendKeys end");
}

- (void)appDidDeactivate:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  self.lastDeactivatedApplication = [userInfo objectForKey:NSWorkspaceApplicationKey];
  NSLog(@"deactivated app=%@", self.lastDeactivatedApplication);
}

- (void)appDidActivate:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSRunningApplication *app = [userInfo objectForKey:NSWorkspaceApplicationKey];
  if ([app isEqual:self.targetApplication]) {
    [self doSendKeys];
    self.targetApplication = nil;
  }
}

- (void)doSendKeys {
  NSLog(@"Do start sendkeys");
  pid_t pid = [self.targetApplication processIdentifier];
  NSLog(@"pid=%d", pid);
  ProcessSerialNumber psn;
  GetProcessForPID(pid, &psn);

  NSString *userId = @"_YOUR_USER_ID_HERE_";
  NSString *password = @"_YOUR_PASSWORD_HERE_";
  NSString *characters = [NSString stringWithFormat:@"%@\t%@\n", userId, password];
  CGEventSourceRef eventSource = CGEventSourceCreate(kCGEventSourceStatePrivate);
  UniChar buffer;
  for (int i = 0; i < [characters length]; i++) {
    [characters getCharacters:&buffer range:NSMakeRange(i, 1)];
    CGEventRef keyEventDown = CGEventCreateKeyboardEvent(eventSource, 0, true);
    CGEventKeyboardSetUnicodeString(keyEventDown, 1, &buffer);
    CGEventPostToPSN(&psn, keyEventDown);
    CFRelease(keyEventDown);
  }
  CFRelease(eventSource);
}


- (void)applicationWillTerminate:(NSNotification *)notification {
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

@end
