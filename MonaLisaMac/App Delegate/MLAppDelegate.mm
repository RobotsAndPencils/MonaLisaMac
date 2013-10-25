//
//  MLAppDelegate.m
//  MonaLisaMac
//
//  Created by Brandon on 10/22/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLAppDelegate.h"
#import "CocoaOpenNI.h"
#import "DepthView.h"
#import "NSTimer+BlocksKit.h"
#import "Skeleton.h"
#import "MLMonaLisaWindowController.h"
#import "MLDepthMapWindowController.h"

@interface MLAppDelegate ()

@property (strong, nonatomic) MLMonaLisaWindowController *monaLisaWindowController;
@property (strong, nonatomic) MLDepthMapWindowController *depthMapWindowController;

@end

@implementation MLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[CocoaOpenNI sharedOpenNI] startWithConfigPath:[[NSBundle mainBundle] pathForResource:@"KinectConfig" ofType:@"xml"]];
    [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 block:^(NSTimer *timer){
        if ([CocoaOpenNI sharedOpenNI].started) {
            // Sometimes we get a crash in here
            [[CocoaOpenNI sharedOpenNI] context].WaitAndUpdateAll();
            [self.depthMapWindowController update];
        }
    } repeats:YES];

    [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 block:^(NSTimer *timer){
        XnUserID userID = [[CocoaOpenNI sharedOpenNI] firstTrackingUser];
        if (!userID) return;

        Skeleton *firstSkeleton = [CocoaOpenNI sharedOpenNI].skeletons[@(userID)];
        XnVector3D position = firstSkeleton.head.position;
        if (self.monaLisaWindowController) {
            [self.monaLisaWindowController updateEyeLocationWithHeadPosition:position];
        }
    } repeats:YES];

    [self showDepthImage:nil];
    [self showMonaLisa:nil];
}

- (IBAction)showDepthImage:(id)sender {
    self.depthMapWindowController = [[MLDepthMapWindowController alloc] initWithWindowNibName:@"MLDepthMapWindow"];
    [self.depthMapWindowController showWindow:nil];
    [self.depthMapWindowController.window makeMainWindow];
}

- (IBAction)showMonaLisa:(id)sender {
    self.monaLisaWindowController = [[MLMonaLisaWindowController alloc] initWithWindowNibName:@"MLMonaLisaWindow"];
    [self.monaLisaWindowController showWindow:nil];
    [self.monaLisaWindowController.window makeMainWindow];
}

@end