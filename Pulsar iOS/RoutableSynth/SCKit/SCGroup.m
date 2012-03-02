//
//  SCGroup.m
//  Artikulator
//
//  Created by Luke Iannini on 6/26/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCGroup.h"

@interface SCGroup ()

@end

#define kSCDefaultNodeID 0
#define kSCUnassignedNodeID -1

@implementation SCGroup

+ (SCGroup *)defaultGroup
{
    static SCGroup *defaultGroup = nil;
    if (!defaultGroup) 
    {
        defaultGroup = [[self alloc] init];
        defaultGroup.nodeID = kSCDefaultNodeID;
    }
    return defaultGroup;
}

- (id)init 
{
    self = [super init];
    if (self) 
    {
        nodeID = kSCUnassignedNodeID;
    }
    return self;
}

+ (SCGroup *)group
{
    return [self groupSendLater:NO];
}

+ (SCGroup *)groupSendLater:(BOOL)sendLater
{
    SCGroup *group = [[self alloc] init];
    if (!sendLater) 
    {
        [group send];
    }
    return group;
}

- (void)freeAll
{
    OSCMessage *message = [[self class] g_freeAllMessageWithNodeID:self.nodeID];
    [SCBundle sendMessage:message];
}

- (void)dumpTree
{
    OSCMessage *message = [[self class] g_dumpTreeMessageWithNodeID:self.nodeID printControlValues:YES];
    [SCBundle sendMessage:message];
}

- (SCNodeID)nodeID
{
    if (nodeID == kSCUnassignedNodeID) 
    {
        self.nodeID = [[SCServer sharedServer] requestNodeID];
    }
    return nodeID;
}

- (OSCMessage *)message
{
    return [SCGroup g_newMessageWithNodeID:self.nodeID 
                                 addAction:self.addAction 
                              targetNodeID:self.target.nodeID];
}

#pragma mark - Message Creation

+ (OSCMessage *)g_newMessageWithNodeID:(SCNodeID)groupID
{
    return [self g_newMessageWithNodeID:groupID 
                              addAction:SCAddToTailAction 
                           targetNodeID:kSCDefaultNodeID];
}

+ (OSCMessage *)g_newMessageWithNodeID:(SCNodeID)groupID
                             addAction:(SCAddAction)addAction
                          targetNodeID:(SCNodeID)targetNodeID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/g_new"];
    [message addInt:groupID];
    [message addInt:addAction];
    [message addInt:targetNodeID]; // add to default group
    return message;
}

+ (OSCMessage *)g_freeAllMessageWithNodeID:(SCNodeID)groupID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"g_freeAll"];
    [message addInt:groupID];
    return message;
}

+ (OSCMessage *)g_dumpTreeMessageWithNodeID:(SCNodeID)groupID printControlValues:(BOOL)printControlValuesOfSynths
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/g_dumpTree"];
    [message addInt:groupID];
    [message addInt:printControlValuesOfSynths];
    return message;
}

@end
