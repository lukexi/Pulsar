//
//  SCGroup.h
//  Artikulator
//
//  Created by Luke Iannini on 6/26/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNode.h"

@interface SCGroup : SCNode

+ (SCGroup *)defaultGroup;

+ (SCGroup *)group;
+ (SCGroup *)groupSendLater:(BOOL)sendLater;

- (void)freeAll;
- (void)dumpTree;

#pragma mark - Message Creation

// Add to tail, default group
+ (OSCMessage *)g_newMessageWithNodeID:(SCNodeID)groupID;

+ (OSCMessage *)g_newMessageWithNodeID:(SCNodeID)groupID
                             addAction:(SCAddAction)addAction
                          targetNodeID:(SCNodeID)targetNodeID;

+ (OSCMessage *)g_freeAllMessageWithNodeID:(SCNodeID)groupID;
+ (OSCMessage *)g_dumpTreeMessageWithNodeID:(SCNodeID)groupID printControlValues:(BOOL)printControlValuesOfSynths;
@end
