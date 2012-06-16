//
//  SCServer.h
//  Artikulator
//
//  Created by Luke Iannini on 6/28/10.
//  Copyright 2010 P.W. Worm & Co & Sons All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVOSC.h"

@class SCNode;

#define SCTransientNodeID -1
#define SCServerSyncDelay 0.05

extern NSString *SCServerSyncIDKey;
extern NSString *SCServerDidSyncNotification;
extern NSString *SCServerNodeDidEndNotification;

extern NSString *SCServerNodeIDKey;

typedef NSInteger SCNodeID;
typedef NSInteger SCBusID;
typedef NSInteger SCBufferNumber;

// New typesafe Obj-C Enums
//NS_ENUM(NSUInteger, SCSynthRate) {
//    SCSynthControlRate,
//    SCSynthAudioRate
//};

typedef enum 
{
    SCSynthControlRate,
    SCSynthAudioRate
} SCSynthRate;

//NS_ENUM(NSUInteger, SCAddAction)
//{
//    SCAddToHeadAction = 0,
//    SCAddToTailAction,
//    SCAddBeforeAction,
//    SCAddAfterAction,
//    SCReplaceAction
//};

typedef enum 
{
    SCAddToHeadAction = 0,
    SCAddToTailAction,
    SCAddBeforeAction,
    SCAddAfterAction,
    SCReplaceAction
} SCAddAction;

@interface SCServer : NSObject <OSCDelegateProtocol>
{
    
}

+ (id)sharedServer;

- (void)dumpTree;
- (void)postAllocatedNodeIDs;

- (void)clearScheduler;

// Send with default sync delay
- (void)sendMessageInBundle:(OSCMessage *)message;

- (void)sendBundle:(OSCBundle *)bundle;
- (void)sendMessage:(OSCMessage *)message;

- (void)freeAll;

- (void)addLimiter;

- (void)dumpOSC:(BOOL)flag;

- (void)freeNode:(SCNode *)aNode uponCompletionOfNode:(SCNode *)endingNode;

#pragma mark - Groups

#pragma mark - Busses
- (SCBusID)requestBusID;
- (void)freeBusID:(SCBusID)busID;

#pragma mark - Nodes
- (SCNodeID)requestNodeID;
- (void)freeNodeID:(SCNodeID)nodeID;

#pragma mark - Buffers
- (NSInteger)requestBufferNumber;
- (void)freeBufferNumber:(SCBufferNumber)bufferNumber;

@end
