//
//  QiKeychainPasswordItem.h
//  QiKeychain
//
//  Created by wangyongwang on 2019/1/29.
//  Copyright © 2019年 QiShare. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString* const QikeychainService;

@interface QiKeychainItem : NSObject

+ (NSError *)saveKeychainWithService:(NSString *)service
                             account:(NSString *)account
                            password:(NSString *)password;

+ (NSError *)deleteWithService:(NSString *)service
                       account:(NSString *)account;

/**
 查询的结果在 [keychainError.userInfo valueForKey:NSLocalizedDescriptionKey]
 */
+ (NSError *)queryKeychainWithService:(NSString *)service
                              account:(NSString *)account;

+ (NSError *)updateKeychainWithService:(NSString *)service
                               account:(NSString *)account
                              password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
