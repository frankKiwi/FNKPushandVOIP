//
//  UploadData.m
//  VoIPTest
//
//  Created by LWW on 2021/4/1.
//  Copyright © 2021 oopsr. All rights reserved.
//

#import "UploadData.h"

@implementation UploadData

+ (void)gitUpTokenUrlString:(NSString *)url
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
