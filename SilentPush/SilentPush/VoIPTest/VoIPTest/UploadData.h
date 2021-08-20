//
//  UploadData.h
//  VoIPTest
//
//  Created by LWW on 2021/4/1.
//  Copyright © 2021 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadData : NSObject
+ (void)gitUpTokenUrlString:(NSString *)url
withToken:(NSString *)token
  success:(void (^)(id responseObject))success
                    failure:(void (^) (id error))failure;
@end

NS_ASSUME_NONNULL_END
