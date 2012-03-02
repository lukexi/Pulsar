//
//  SCBundle.m
//  Artikulator
//
//  Created by Luke Iannini on 8/17/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "SCBundle.h"
#import "SCServer.h"
#import "VVOSC.h"
#import "OSCValue+Additions.h"
#import "OSCMessage+AddArguments.h"

@interface SCBundle ()
{
    
}

+ (SCBundle *)defaultBundle;

- (void)beginBundle;
- (void)beginBundleForTimeStamp:(NSDate *)timeStamp;
- (void)commitBundle;

- (void)bundleAtTimeStamp:(NSDate *)timeStamp messages:(SCBundleBlock)block;
- (void)sendMessage:(OSCMessage *)message;

- (void)sync;
- (void)waitForSyncID:(id)syncID;

@property (nonatomic, strong) OSCBundle *currentBundle;
@property (nonatomic, strong) NSDate *currentTimeStamp;
@property (nonatomic) NSUInteger nextSyncID;

@property (nonatomic, strong) NSMutableDictionary *conditionsBySyncID;
@property (nonatomic, strong) NSMutableArray *waitingSyncIDs;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation SCBundle
@synthesize currentBundle, currentTimeStamp;
@synthesize nextSyncID, conditionsBySyncID, queue, waitingSyncIDs;

+ (SCBundle *)bundle
{
    return [[self alloc] init];
}

+ (SCBundle *)defaultBundle
{
    static SCBundle *defaultBundle = nil;
    if (!defaultBundle) 
    {
        defaultBundle = [[self alloc] init];
    }
    return defaultBundle;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCServerDidSyncNotification object:nil];
}

- (id)init 
{
    self = [super init];
    if (self) 
    {
        conditionsBySyncID = [[NSMutableDictionary alloc] init];
        waitingSyncIDs = [[NSMutableArray alloc] init];
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverDidSync:) name:SCServerDidSyncNotification object:nil];
    }
    return self;
}

- (void)beginBundle
{
    [self beginBundleForTimeStamp:nil];
}

- (void)beginBundleForTimeStamp:(NSDate *)timeStamp
{
    if (!self.currentBundle) 
    {
        self.currentBundle = [OSCBundle create];
        self.currentBundle.timeStamp = timeStamp;
        self.currentTimeStamp = timeStamp;
        //PLog(kSCBUNDLE_DEBUG, @"-BEGAN %@-", self.currentBundle);
        //NSLog(@"-BEGAN %@-", self.currentBundle);
    }
}

+ (void)bundleMessages:(SCBundleBlock)block
{
    [self bundleAtTimeStamp:nil 
                   messages:block];
}

+ (void)bundleAtTimeStamp:(NSDate *)timeStamp messages:(SCBundleBlock)block
{
    [[self defaultBundle] bundleAtTimeStamp:timeStamp 
                                   messages:block];
}

- (void)bundleAtTimeStamp:(NSDate *)timeStamp messages:(SCBundleBlock)block
{
    [self beginBundleForTimeStamp:timeStamp];
    if (block) 
    {
        block();
    }
    [self commitBundle];
}

+ (void)sendMessage:(OSCMessage *)message
{
    [[self defaultBundle] sendMessage:message];
}

- (void)sendMessage:(OSCMessage *)message
{
    if (self.currentBundle) 
    {
        //PLog(kSCBUNDLE_DEBUG, @"   %@", [message sc_simpleDescription]);
        //NSLog(@"   %@", [message sc_simpleDescription]);
        [self.currentBundle addElement:message];
    }
    else
    {
        [self beginBundle];
        [self sendMessage:message];
        [self commitBundle];
    }
}

- (void)commitBundle
{
    if (self.currentBundle) 
    {
        OSCBundle *bundle = self.currentBundle;
        //NSLog(@"-COMMITTED %@-", bundle);
        [self.queue addOperationWithBlock:^
        {
            if (!bundle.timeStamp) 
            {
                bundle.timeStamp = [NSDate dateWithTimeIntervalSinceNow:SCServerSyncDelay];
            }
            [[SCServer sharedServer] sendBundle:bundle];
        }];
        self.currentBundle = nil;
    }
}

+ (void)sync
{
    [[self defaultBundle] sync];
}

- (void)sync
{
    [self syncWithCompletion:nil];
}

+ (void)syncWithCompletion:(SCBundleBlock)completion
{
    [[self defaultBundle] syncWithCompletion:completion];
}

- (void)syncWithCompletion:(SCBundleBlock)completion
{
    NSUInteger syncIDValue = nextSyncID++;
    
    NSNumber *syncID = [NSNumber numberWithUnsignedInteger:syncIDValue];
    
    BOOL shouldContinueBundlingAfterSync = NO;
    if (self.currentBundle)
    {
        shouldContinueBundlingAfterSync = YES;
        [self commitBundle];
    }
    
    [self.queue addOperationWithBlock:^(void)
    {
        OSCMessage *message = [OSCMessage createWithAddress:@"/sync"];
        [message addInt:syncIDValue];
        [[SCServer sharedServer] sendMessageInBundle:message];
    }];
    
    [self waitForSyncID:syncID];
    
    if (completion) 
    {
        [self.queue addOperationWithBlock:^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion();
            }];
        }];
    }
    
    if (shouldContinueBundlingAfterSync) 
    {
        [self beginBundle];
    }
}

- (void)waitForSyncID:(id)syncID
{
    BOOL bundleWasInProgress = self.currentBundle != nil;
    [self commitBundle];
    
    NSCondition *syncCondition = [[NSCondition alloc] init];
    
    [self.conditionsBySyncID setObject:syncCondition forKey:syncID];
    [self.waitingSyncIDs addObject:syncID];
    
    __weak SCBundle *weakSelf = self;
    [self.queue addOperationWithBlock:^{
        [syncCondition lock];
        //PLog(kSCBUNDLE_DEBUG, @"Waiting for sync ID: %@", syncID);
        
        while ([weakSelf.waitingSyncIDs containsObject:syncID]) 
        {
            [syncCondition wait];
        }
        //PLog(kSCBUNDLE_DEBUG, @"Finished sync ID!: %@", syncID);
        
        [syncCondition unlock];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf.waitingSyncIDs removeObject:syncID];
            [weakSelf.conditionsBySyncID removeObjectForKey:syncID];
        }];
    }];
    
    if (bundleWasInProgress) 
    {
        [self beginBundleForTimeStamp:self.currentTimeStamp];
    }
}

- (void)serverDidSync:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSNumber *syncID = [[notification userInfo] objectForKey:SCServerSyncIDKey];
        NSCondition *condition = [self.conditionsBySyncID objectForKey:syncID];
        [condition lock];
        [self.waitingSyncIDs removeObject:syncID];
        [condition signal];
        [condition unlock];
    }];
}

@end
