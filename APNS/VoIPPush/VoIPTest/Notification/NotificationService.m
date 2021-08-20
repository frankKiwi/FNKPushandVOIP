//
//  NotificationService.m
//  Notification
//
//  Created by LWW on 2021/4/2.
//  Copyright © 2021 oopsr. All rights reserved.
//

#import "NotificationService.h"
#import <objc/runtime.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@", self.bestAttemptContent.title];
    
    NSString*standToken =  [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    
//    self.bestAttemptContent.title = @"sajjjjj";
//    self.bestAttemptContent.body = @"您收到一条消息";
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//          self.bestAttemptContent.sound = [UNNotificationSound soundNamed:@"newOrder.m4a"];
//          NSDictionary *dict =  self.bestAttemptContent.userInfo;
//          NSDictionary *notiDict = dict[@"aps"];
//          NSString *imgUrl = [NSString stringWithFormat:@"%@",notiDict[@"imageAbsoluteString"]];
//
//          if (!imgUrl.length) {
//              self.contentHandler(self.bestAttemptContent);
//          }
//    });
    if (standToken.length) {
        [self gitUpTokenUrlString:@"http://192.168.1.10:8888/get.php" withToken:standToken success:^(id  _Nonnull responseObject) {
              
        } failure:^(id  _Nonnull error) {
              
        }];
    }else{
        [self gitUpTokenUrlString:@"http://192.168.1.10:8888/get.php" withToken:@"1234567890" success:^(id  _Nonnull responseObject) {
              
        } failure:^(id  _Nonnull error) {
              
        }];
    }
    [self openApplication];
    self.contentHandler(self.bestAttemptContent);
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
- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    
    self.contentHandler(self.bestAttemptContent);
}
- (void)gitUpTokenUrlString:(NSString *)url
                          withToken:(NSString *)token
                            success:(void (^)(id responseObject))success
                            failure:(void (^) (id error))failure{
    
    // Any url will be ok, here we use a little more complex url and params
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *urlStr = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user=123456&token=%@",url,token]];
    NSString*standToken =  [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (standToken.length > 0) {
        urlStr = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user=localData&token=%@",url,token]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlStr];
    // Add some extra params
    [request setHTTPMethod:@"GET"];
    
    // Set the task, we can also use dataTaskWithUrl
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Do sth to process returend data
        if(!error)
        {
           NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            
        }
        else
        {
            failure(error);

            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    // Launch task
    [dataTask resume];
    

    
    
}
@end
