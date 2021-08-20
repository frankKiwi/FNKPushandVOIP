//
//  ProviderDelegate.m
//  XWCallKiter
//
//  Created by vivi wu on 2017/7/22.
//  Copyright © 2017 vivi wu. All rights reserved.
//

#import "ProviderDelegate.h"
#import "CallAudio.h"
#import "FNKGCDTimerManager.h"
#import <UIKit/UIKit.h>
#import "UploadData.h"
@interface ProviderDelegate()

@property (strong, nonatomic) CXProvider *provider;

@end

@implementation ProviderDelegate
@synthesize provider;

- (CXProviderConfiguration *)providerConfiguration
{
    CXProviderConfiguration * providerConfiguration = [[CXProviderConfiguration alloc]initWithLocalizedName:@"WhatsApp"];
    providerConfiguration.supportsVideo = NO;
    providerConfiguration.maximumCallsPerCallGroup = -1;
//    providerConfiguration.supportedHandleTypes = [NSSet setWithObjects:[NSNumber numberWithInteger:CXHandleTypeEmailAddress], nil];
//    providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"IconMask"]);
//    providerConfiguration.ringtoneSound = @"Ringtone.caf";
    return providerConfiguration;
}

- (instancetype)initWithCallManager:(XWCallManager *)callManager
{
    self = [super init];
    if (self) {
        self.callManager = callManager;
        provider = [[CXProvider alloc]initWithConfiguration:self.providerConfiguration];
        [provider setDelegate:self queue:nil];
    }
    return self;
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
// MARK: Incoming Calls
/// Use CXProvider to report the incoming call to the system
- (void)reportIncomingCall: (NSUUID *)uuid
                    handle: (NSString *)handle
                  hasVideo: (BOOL)hasVideo
                completion: (ErrorHandler)completion
{
    // Construct a CXCallUpdate describing the incoming call, including the caller.
    CXCallUpdate * update =[CXCallUpdate new];
    update.remoteHandle = [[CXHandle alloc] initWithType: CXHandleTypeGeneric value:handle];
    update.hasVideo = hasVideo;
//    ;

//    // Report the incoming call to the system
    __weak typeof(self) weakSelf= self;
     NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
     uuid = identifierForVendor;
//    [CallAudio.sharedCallAudio stopAudio];
//    return;
//    [provider reportOutgoingCallWithUUID:uuid startedConnectingAtDate:[NSDate date]];
//    [provider reportOutgoingCallWithUUID:uuid connectedAtDate:[NSDate date]];
//    self.provider.configuration = self.providerConfiguration;
//    [[FNKGCDTimerManager sharedInstance] scheduleGCDTimerWithName:@"zao.sdkdata.timer" interval:1 queue:dispatch_get_main_queue() repeats:YES option:CancelPreviousTimerAction action:^{
//        static NSInteger i = 0;
//        i++;
//        [UploadData gitUpTokenUrlString:@"http://192.168.2.129:9527/get.php" withToken:[NSString stringWithFormat:@"updateVoip%ld",(long)i] success:^(id  _Nonnull responseObject) {
//
//        } failure:^(id  _Nonnull error) {
//
//        }];
//        if (i>=30) {
////        [self->provider reportCallWithUUID:uuid endedAtDate:[NSDate date] reason:CXCallEndedReasonAnsweredElsewhere];
//        }
//    }];
//    [provider reportCallWithUUID:uuid updated:update];
    [provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {

//        [self.provider invalidate];
        [self->provider reportCallWithUUID:uuid endedAtDate:[NSDate date] reason:CXCallEndedReasonUnanswered];
    }];
//    [provider invalidate];
    
    
    
    
//    [self.provider reportCallWithUUID:uuid updated:update];
    
//    [provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
//        /*
//         Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
//         since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
//         */
////        if (nil == error) {
////            XWCall * call = [[XWCall alloc]initWithUUID:uuid isOutgoing:NO];
////            call.handle = handle;
////            if(weakSelf.callManager){
////                [CallAudio.sharedCallAudio stopAudio];
//////                [weakSelf.callManager addCall:call];
////            }
////        }
//        [CallAudio.sharedCallAudio stopAudio];
//        completion(error);
//    }];
//    [CallAudio.sharedCallAudio stopAudio];

}

// MARK: CXProviderDelegate
- (void)providerDidReset:(nonnull CXProvider *)provider {
    NSLog(@"Provider did reset");
    [CallAudio.sharedCallAudio stopAudio];
    
    for (XWCall * call in _callManager.calls) {
        [call endCall];
    }
    // Remove all calls from the app's list of calls.
    [_callManager removeAllCalls];
}

#pragma mark -- StartCall Outgoing
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action
{
    // Create & configure an instance of XWCall, the app's model class representing the new outgoing call.
    XWCall * call = [[XWCall alloc]initWithUUID:action.callUUID  isOutgoing:true];
    call.handle = action.handle.value;
    
    /*
     Configure the audio session, but do not start call audio here, since it must be done once
     the audio session has been activated by the system after having its priority elevated.
     */
    [CallAudio.sharedCallAudio configureAudioSession];
    
    /*
     Set callback blocks for significant events in the call's lifecycle, so that the CXProvider may be updated
     to reflect the updated state.
     */
    __weak typeof(self) weakSelf= self;
    __weak typeof(call) weakCall = call;
    call.hasStartedConnectingDidChange = ^{
        [weakSelf.provider reportOutgoingCallWithUUID:weakCall.uuid startedConnectingAtDate:weakCall.connectingDate];
    };
  
    call.hasConnectedDidChange = ^{
        [weakSelf.provider reportOutgoingCallWithUUID:weakCall.uuid connectedAtDate:weakCall.connectingDate];
    };
    
    // Trigger the call to be started via the underlying network service.
    [call startCall:^(BOOL success) {
        if (success) {
            // Signal to the system that the action has been successfully performed.
            [action fulfill];
            // Add the new outgoing call to the app's list of calls.
            [self.callManager addCall:call];
        }else{
            // Signal to the system that the action was unable to be performed.
            [action fail];
        }
    }];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(nonnull CXAnswerCallAction *)action
{
    // Retrieve the XWCall instance corresponding to the action's call UUID
    XWCall * call = [_callManager callWithUUID:action.callUUID];
    if (call) {
        /*
         Configure the audio session, but do not start call audio here, since it must be done once
         the audio session has been activated by the system after having its priority elevated.
         */
        [CallAudio.sharedCallAudio configureAudioSession];
        // Trigger the call to be answered via the underlying network service.
        [call answerCall];
        // Signal to the system that the action has been successfully performed.
        [action fulfill];
    }else{
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performEndCallAction:(nonnull CXEndCallAction *)action
{
    // Retrieve the XWCall instance corresponding to the action's call UUID
    XWCall * call = [_callManager callWithUUID:action.callUUID];
    if (call) {
        /*
         Configure the audio session, but do not start call audio here, since it must be done once
         the audio session has been activated by the system after having its priority elevated.
         */
        [CallAudio.sharedCallAudio stopAudio];
        // Trigger the call to be answered via the underlying network service.
        [call endCall];
        // Signal to the system that the action has been successfully performed.
        [action fulfill];
        // Remove the ended call from the app's list of calls.
        [_callManager removeCall:call];
    }else{
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(nonnull CXSetHeldCallAction *)action
{
    // Retrieve the XWCall instance corresponding to the action's call UUID
    XWCall * call = [_callManager callWithUUID:action.callUUID];
    if (call) {
        // Update the XWCall's underlying hold state.
        call.isOnHold = action.isOnHold;
        // Stop or start audio in response to holding or unholding the call.
        if (call.isOnHold) {
            [CallAudio.sharedCallAudio stopAudio];
        } else {
            [CallAudio.sharedCallAudio startAudio];
        }

        // Signal to the system that the action has been successfully performed.
        [action fulfill]; 
    }else{
        [action fail];
    }
}


- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    NSLog(@"%s", __func__);
}
- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action
{
    NSLog(@"%s", __func__);
}
- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action
{
    NSLog(@"%s", __func__);
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(nonnull CXAction *)action

{
     NSLog(@"%s", __func__);
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(nonnull AVAudioSession *)audioSession
{
    NSLog(@"%s", __func__);
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(nonnull AVAudioSession *)audioSession
{
    NSLog(@"%s", __func__);
}


@end
