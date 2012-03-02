//
//  SCBundle.h
//  Artikulator
//
//  Created by Luke Iannini on 8/17/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVOSC.h"

typedef void(^SCBundleBlock)(void);

@interface SCBundle : NSObject

+ (void)bundleMessages:(SCBundleBlock)block;
+ (void)bundleAtTimeStamp:(NSDate *)timeStamp messages:(SCBundleBlock)block;

+ (void)sendMessage:(OSCMessage *)message;

+ (void)sync;
// Completion block will be called on the main thread
+ (void)syncWithCompletion:(SCBundleBlock)completion;

+ (SCBundle *)bundle;

- (void)bundleAtTimeStamp:(NSDate *)timeStamp messages:(SCBundleBlock)block;
- (void)sendMessage:(OSCMessage *)message;
- (void)sync;
- (void)syncWithCompletion:(SCBundleBlock)completion;

@end
