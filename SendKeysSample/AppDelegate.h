//
//  AppDelegate.h
//  SendKeysSample
//
//  Created by Hiroaki Nakamura on 2013/07/29.
//
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property NSRunningApplication *lastDeactivatedApplication;
@property NSRunningApplication *targetApplication;
- (IBAction)sendKeys:(id)sender;

@end
