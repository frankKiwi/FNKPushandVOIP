//
//  PKPushRegistry+Fix.m
//  VoIPTest
//
//  Created by LWW on 2021/4/1.
//  Copyright © 2021 oopsr. All rights reserved.
//

#import <objc/runtime.h>
#import <PushKit/PushKit.h>

@interface PKPushRegistry (Fix)
@end

@implementation PKPushRegistry (Fix)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(_terminateAppIfThereAreUnhandledVoIPPushes);
        SEL swizzledSelector = @selector(doNotCrash);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
            class_addMethod(class,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        [super load];
    });
}

#pragma mark - Method Swizzling

- (void)doNotCrash {
    NSLog(@"Unhandled VoIP Push");
}

@end
