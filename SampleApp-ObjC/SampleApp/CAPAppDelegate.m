//
//  FTAppDelegate.m
//  FastTrains
//
//  Created by Darren Harris on 18/02/14.
//  Copyright (c) 2014 Capito Systems. All rights reserved.
//

#import "CAPAppDelegate.h"

@import CapitoSpeechKit;

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation CAPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    CAPSettings *settings = [CAPSettings getInstance];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *_majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *_minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString *_appVersion = [NSString stringWithFormat:@"%@.%@", _majorVersion, _minorVersion];
    [settings setAppVersion:_appVersion];
    [settings setMode:CAPModeTest];
    settings.silenceDetectionTime = 3.0;
    CapitoController *controller = [CapitoController getInstance];
    [controller setupWithID:@"a2d65251-0fe4-476f-994d-5dce055f555f" host:@"sysportal.test.a.cloud.capitosystems.com" port:[NSNumber numberWithInt:443] useSSL:YES];
    
    NSString *status=[controller connect];
    NSLog(@"Capito Speech Kit status [%@]",status);
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[CapitoController getInstance] disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[CapitoController getInstance] connect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CapitoController getInstance] disconnect];
}

@end
