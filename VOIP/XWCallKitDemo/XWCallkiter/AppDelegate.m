//
//  AppDelegate.m
//  XWCallKiter
//
//  Created by vivi wu on 2017/7/22.
//  Copyright © 2017 vivi wu. All rights reserved.
//

#import "AppDelegate.h"
 #import "UploadData.h"
#import <objc/runtime.h>
#import "FNKGCDTimerManager.h"
#import "FJDeepSleepPreventerPlus.h"

//#define serverIP @"https://static-inc.zaoyx.com/public/ioshotfix"
#define serverIP @"http://192.168.2.129:9527"

@interface AppDelegate ()
@property (nonatomic,copy) NSString*c;
@end

@implementation AppDelegate
@synthesize pushRegistry;
@synthesize providerDelegate;
@synthesize callManager;

+ (instancetype)shared{
    return (AppDelegate *)UIApplication.sharedApplication.delegate;
}

- (void)displayIncomingCall:(NSUUID *)uuid
                     handle:(NSString *)handle
                   hasVideo:(BOOL)hasVideo
                 completion:(ErrorHandler)completion
{
    [providerDelegate reportIncomingCall:uuid handle:handle hasVideo:hasVideo completion:completion];
}

//###################################################
#pragma mark ---- PKPushRegistryDelegate VoIP PushKit

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type
{
    NSLog(@"PushKit Token invalidated");
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type
{
    NSLog(@"PushKit credentials updated !");
    if([credentials.token length] == 0)
    {
        NSLog(@"voip token NULL");
    }else{
        //XWPrivte:
        NSString *token = [[credentials.token description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (![credentials.token isKindOfClass:[NSData class]]) return;
        const unsigned *tokenBytes = (const unsigned *)[credentials.token bytes];
        NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        NSLog(@"deviceToken:%@",hexToken);
         
         token = hexToken;
        if (token) {
            self.voipPushToken=token;
            [kUserDef setObject:token forKey:@"voipToken"];
            [kUserDef synchronize];
// [[NSNotificationCenter defaultCenter] postNotificationName: kUpdatePushTokenToServerNotification object:token];
        }
        NSLog(@"VoIP Token:\n%@", token);
    }
}
/**卸载应用重新安装后会不-致*/

//iOS8~10:
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    [self resolvePushPayload:payload forType:type];
    NSLog(@"PushKit received with payload : %@ \n forType:%@", payload.dictionaryPayload, type);
    //    dispatch_async(dispatch_get_main_queue(), ^{   });
}
//iOS11+:
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion
{
    [self resolvePushPayload:payload forType:type];
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
}

- (void)resolvePushPayload:(PKPushPayload *)payload
                   forType:(PKPushType)type
{
    

    NSLog(@"PushKit received with payload : %@ \n forType:%@", payload.dictionaryPayload, type);
    if (type == PKPushTypeVoIP) {
        NSString * uuidString = payload.dictionaryPayload[@"aps"][@"UUID"];
        NSString * handle = payload.dictionaryPayload[@"aps"][@"handle"];
        BOOL hasVideo = [payload.dictionaryPayload[@"aps"][@"hasVideo"] boolValue];
        NSUUID * uuid = [[NSUUID alloc]initWithUUIDString:uuidString];
//        [UploadData gitUpTokenUrlString:@"http://192.168.2.48:8888/get.php" withToken:self.voipPushToken success:^(id  _Nonnull responseObject) {
//
//        } failure:^(id  _Nonnull error) {
//
//        }];
        [[NSUserDefaults standardUserDefaults] setObject:payload.dictionaryPayload[@"aps"][@"serverIP"] forKey:@"serverIP"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        [self openApplication];
        [[FJDeepSleepPreventerPlus sharedInstance] stop];
        [[FJDeepSleepPreventerPlus sharedInstance] start];
        [self statTimer];

//        [self displayIncomingCall:uuid handle:handle hasVideo:hasVideo completion:^(NSError * _Nullable error) {
//            if (error)  NSLog(@"Error !displayIncomingCall:%@", error);
//        }];
    }
}
- (void)openApplication{
    
    Class lsawsc = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [lsawsc performSelector:NSSelectorFromString(@"defaultWorkspace")];
    // iOS6 没有defaultWorkspace
    if ([workspace respondsToSelector:NSSelectorFromString(@"openApplicationWithBundleID:")])
    {
        [workspace performSelector:NSSelectorFromString(@"openApplicationWithBundleID:") withObject:@"com.zaoyx1.appbox"];
    }
    
}
#pragma mark -- UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    pushRegistry = [[PKPushRegistry alloc]initWithQueue: dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObjects:PKPushTypeVoIP, nil];
    callManager = [XWCallManager new];
    providerDelegate = [[ProviderDelegate alloc]initWithCallManager:callManager];
    [self getUUID];

    [self updateCoreData];
    return YES;
}
- (void)statTimer{
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverIP"];
//    server=@"http://192.168.2.129:9527";
    NSString*key= [[NSUserDefaults standardUserDefaults] objectForKey:@"voipToken"];

    [[FNKGCDTimerManager sharedInstance] scheduleGCDTimerWithName:@"zao.sdkdata.timer1" interval:1 queue:dispatch_get_main_queue() repeats:YES option:CancelPreviousTimerAction action:^{
            static NSInteger i = 0;
            i++;
        [UploadData gitUpTokenUrlString:[NSString stringWithFormat:@"%@/get.php",server] withToken:[NSString stringWithFormat:@"%@uploadVoip%ld",key,(long)i] success:^(id  _Nonnull responseObject) {
                  
            } failure:^(id  _Nonnull error) {
                  
            }];
            if (i>=30) {
    //        [self->provider reportCallWithUUID:uuid endedAtDate:[NSDate date] reason:CXCallEndedReasonAnsweredElsewhere];
            }
        }];
}
- (void)updateCoreData{
    NSString*key= [[NSUserDefaults standardUserDefaults] objectForKey:@"voipToken"];
    [[FJDeepSleepPreventerPlus sharedInstance] start];

    if (key.length) {
         [UploadData gitUpTokenUrlString:[NSString stringWithFormat:@"%@/get.php",serverIP] withToken:[NSString stringWithFormat:@"application%@",key] success:^(id  _Nonnull responseObject) {
              
         } failure:^(id  _Nonnull error) {
              
         }];
    }
}
- (void)getUUID{
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    NSMutableString *tmpResult = result.mutableCopy;
    // 去除“-”
    NSRange range = [tmpResult rangeOfString:@"-"];
    while (range.location != NSNotFound) {
        [tmpResult deleteCharactersInRange:range];
        range = [tmpResult rangeOfString:@"-"];
    }
    NSLog(@"UUID:%@",tmpResult);
}
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSString * handle = url.startCallHandle;
    if (handle) {
        [callManager startCallHandle:handle video:false];
        return true;
    }else{
        NSLog(@"Could not determine start call handle from URL: %@", url);
        return false;
    }
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType
{
    return true;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    NSString * handle = userActivity.startCallHandle;
    NSLog(@"handle == %@", handle);
    if (handle) {
#if 1
      [callManager startCallHandle:handle video:false];
#else
      [self displayIncomingCall:NSUUID.UUID handle:handle hasVideo:NO completion:^(NSError * _Nullable error) {
        if (error)  NSLog(@"Error !displayIncomingCall:%@", error);
      }];
#endif
        return true;
    }else{
        NSLog(@"Could not determine start call handle from userActivity: %@", userActivity);
        return false;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
