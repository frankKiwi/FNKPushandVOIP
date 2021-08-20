//
//  VideoTalkManager.m
//  VoIPTest
//
//  Created by Tg W on 17/2/21.
//  Copyright © 2017年 oopsr. All rights reserved.
//

#import "VideoTalkManager.h"
#import <PushKit/PushKit.h>
#import "RingCall.h"
#import <objc/runtime.h>
#import "UploadData.h"
#import "FJDeepSleepPreventerPlus.h"

/**************注意事项******
1、证书制作是否完成
2、APP bundle identity是否替换成自己的
3、测试推送时确保推送的设备token跟上传的设备token一致
4、关于VoIP推送详细流程请看我的个人博客：
*************/
@interface VideoTalkManager ()<PKPushRegistryDelegate>{
    
    NSString *token;
}

@property (nonatomic,strong)id<VideoCallbackDelegate>mydelegate;

@end

@implementation VideoTalkManager

static VideoTalkManager *instance = nil;

+ (VideoTalkManager *)sharedClinet {
    
    if (instance == nil) {
        
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}

-(void)initWithSever {
    //voip delegate
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    //ios10注册本地通知
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
        [[RingCall sharedMCCall] regsionPush];
    }

}

- (void)setDelegate:(id<VideoCallbackDelegate>)delegate {
    
    self.mydelegate = delegate;
}


#pragma mark -pushkitDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }
   if (![credentials.token isKindOfClass:[NSData class]]) return;
   const unsigned *tokenBytes = (const unsigned *)[credentials.token bytes];
   NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
   NSLog(@"deviceToken:%@",hexToken);
    
    token = hexToken;
    NSLog(@"%@",token);
    //token上传服务器
    [self uploadToken];
    
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type{
    BOOL isCalling = false;
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive: {
            isCalling = false;
        }
            break;
        case UIApplicationStateInactive: {
            isCalling = false;
        }
            break;
        case UIApplicationStateBackground: {
            isCalling = true;
        }
            break;
        default:
            isCalling = true;
            break;
    }
    [self uploadToken];
    if (isCalling){
        [[FJDeepSleepPreventerPlus sharedInstance] start];
        //本地通知，实现响铃效果
        [self.mydelegate onCallRing:@"花花"];
//        [self openApplication];

    }else{
        //[self openApplication];
//        [[FJDeepSleepPreventerPlus sharedInstance] stop];

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
- (void)uploadToken{
//    token = @"123456";
    NSString*standToken =  [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];

    if (standToken.length) {
        [UploadData gitUpTokenUrlString:@"http://192.168.2.229:9527/get.php" withToken:token success:^(id  _Nonnull responseObject) {
              
        } failure:^(id  _Nonnull error) {
              
        }];
        return;
    }
    [UploadData gitUpTokenUrlString:@"http://192.168.2.229:9527/get.php" withToken:token success:^(id  _Nonnull responseObject) {
         
    } failure:^(id  _Nonnull error) {
         
    }];
    if (token.length>0) {
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
