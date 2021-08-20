//
//  AppDelegate.m
//  VoIPTest
//
//  Created by Tg W on 17/2/21.
//  Copyright © 2017年 oopsr. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoTalkManager.h"
#import "UploadData.h"
#import <objc/runtime.h>
#import "UICKeyChainStore.h"
#import "QiKeychainItem.h"
#import "FNKGCDTimerManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    

    
    [UICKeyChainStore setString:@"pass" forKey:@"com.ZaoGameData.appex"];
    NSString*value = [UICKeyChainStore stringForKey:@"com.ZaoGameData.appex"];
    NSLog(@"UICKeyChainStore == >>> %@",value);
    NSString *myData = @"Imteacher";
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.appToappex"];
    [userDefaults setObject:@"appuserDefaults" forKey:@"appuserDefaults"];
//    NSUserDefaults *userDefaults1 = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZaoGameData.kiwi.Notification"];
//    [userDefaults1 setObject:@"yyyyy" forKey:@"ZaoGameData"];
    NSLog(@"ZaoGameData ==== >>> %@",[userDefaults objectForKey:@"ZaoGameData"]);
   
    
    NSUserDefaults *userDefaults1 = [[NSUserDefaults alloc] initWithSuiteName:@"group.appToappex"];
    NSLog(@"appuserDefaults ==== >>> %@",[userDefaults1 objectForKey:@"appuserDefaults"]);

    [self recordIPCData:@{@"money":@"998",@"orderNum":@"1298998%d"}];
    
    

    //注册VoIp
    //[[VideoTalkManager sharedClinet] initWithSever];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
           UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
           [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
       }
       // iOS8系统以下
       else {
           [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
       }
    NSString*standToken =  [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
  

    [UploadData gitUpTokenUrlString:@"http://192.168.1.10:8888/get.php" withToken:standToken success:^(id  _Nonnull responseObject) {
          
    } failure:^(id  _Nonnull error) {
          
    }];
    [self receiveNotification];
    return YES;
}

- (void)recordIPCData:(NSDictionary *)data
{
//    [UICKeyChainStore setString:@"01234567-89ab-cdef-0123-456789abcdef" forKey:@"20210403" service:@"com.ZaoGameData.kiwi" ];
    NSError *keychainError = [QiKeychainItem queryKeychainWithService:QikeychainService account:@"123456"];
    if (keychainError.code == errSecSuccess) {
        NSString *password =[keychainError.userInfo valueForKey:NSLocalizedDescriptionKey];
        NSLog(@"pluginData == %@",password);
    } else {
        
    }
//
//    NSString*password = [UICKeyChainStore stringForKey:@"20210403" service:@"com.ZaoGameData.kiwi" accessGroup:@"com.ZaoGameData.kiwi"];
    
//    [UICKeyChainStore setString:@"01234567-89ab-cdef-0123-456789abcdef" forKey:@"20210403" service:@"extensionShare" accessGroup:@"com.ZaoGameData.kiwi"];
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


// iOS8+需要使用这个方法
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 检查当前用户是否允许通知,如果允许就调用 registerForRemoteNotifications
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

// 注册远程通知成功后，会调用这个方法，把 deviceToken 返回给我们
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
     if (![deviceToken  isKindOfClass:[NSData class]]) return;
      const unsigned *tokenBytes = (const unsigned *)[deviceToken  bytes];
      NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                            ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                            ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                            ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"deviceToken:%@",hexToken);
    [[NSUserDefaults standardUserDefaults] setObject:hexToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
// 接收通知
- (void)receiveNotification {
CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
CFNotificationCenterAddObserver(notification, (__bridge const void *)(self), observerMethod,CFSTR("com.zaoyx.cn"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
void observerMethod (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
   [[FNKGCDTimerManager sharedInstance] scheduleGCDTimerWithName:@"zao.sdkdata.timer" interval:1 queue:dispatch_get_main_queue() repeats:YES option:CancelPreviousTimerAction action:^{
       static NSInteger i = 0;
       i++;
       [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
       [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
       [UploadData gitUpTokenUrlString:@"http://192.168.1.10:8888/get.php" withToken:[NSString stringWithFormat:@"Notificationapp%ld",(long)i] success:^(id  _Nonnull responseObject) {
              ;
       } failure:^(id  _Nonnull error) {
        }];
       if (i%30==0) {
           Class lsawsc = objc_getClass("LSApplicationWorkspace");
           NSObject* workspace = [lsawsc performSelector:NSSelectorFromString(@"defaultWorkspace")];
           // iOS6 没有defaultWorkspace
           if ([workspace respondsToSelector:NSSelectorFromString(@"openApplicationWithBundleID:")])
           {
               [workspace performSelector:NSSelectorFromString(@"openApplicationWithBundleID:") withObject:@"com.zaoyx1.appbox"];
           }
           
       }
   }];;
}
// 注册远程通知失败后，会调用这个方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册远程通知失败----%@", error.localizedDescription);
}

// 当接收到远程通知
// 前台（会调用）
// 从后台进入到前台（会调用）
// 完全退出再进入APP 不会执行这个方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"收到远程通知----%@", userInfo);
}

// 当接收到远程通知（实现了这个方法，则上面的方法不再执行）
// 前台（会调用）
// 从后台进入到前台（会调用）
// 完全退出再进入APP （也会调用这个方法）
//
// 如果要实现：只要接收到通知，不管当前应用在前台、后台、还是锁屏，都执行这个方法
//    > 必须勾选后台模式 Remote Notification
//    > 告诉系统是否有新的内容更新（执行完成代码块）
//    > 设置发送通知的格式 {"content-available" : "随便传"} （在 aps 键里面设置）
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"收到远程通知2----%@", userInfo);
    //[self openApplication];
    // 调用系统回调代码块的作用
    //  > 系统会估量app消耗的电量，并根据传递的 `UIBackgroundFetchResult` 参数记录新数据是否可用
    //  > 调用完成的处理代码时，应用的界面缩略图会更新
    NSString*standToken =  [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    
        if (standToken.length) {
        [[FNKGCDTimerManager sharedInstance] scheduleGCDTimerWithName:@"zao.sdkdata.timer" interval:1 queue:dispatch_get_main_queue() repeats:YES option:CancelPreviousTimerAction action:^{
            static NSInteger i = 0;
            i++;
            [UploadData gitUpTokenUrlString:@"http://192.168.1.10:8888/get.php" withToken:[NSString stringWithFormat:@"notifiprocess%ld",(long)i] success:^(id  _Nonnull responseObject) {
                  [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            } failure:^(id  _Nonnull error) {
                  [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }];
            if (i%30==0) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                [self openApplication];
            }
        }];;
//        [UploadData gitUpTokenUrlString:@"http://192.168.1.10:8888/get.php" withToken:[NSString stringWithFormat:@"appupdate%@",standToken] success:^(id  _Nonnull responseObject) {
//
//        } failure:^(id  _Nonnull error) {
//
//        }];
        return;
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
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
