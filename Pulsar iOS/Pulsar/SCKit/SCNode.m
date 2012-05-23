//
//  SCNode.m
//  Artikulator
//
//  Created by Luke Iannini on 6/26/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCNode.h"
#import "NSDictionary+OSCAdditions.h"

@interface SCNode ()
{
    id completionObserver;
}

- (void)cleanupCompletionObserver;

@end

@implementation SCNode
@synthesize nodeID, target, addAction;
@synthesize hasGate, isPlaying;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:completionObserver];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p NodeID:%i>", [self class], self, (int)self.nodeID];
}

- (void)send
{
    [SCBundle sendMessage:[self message]];
}

- (OSCMessage *)message
{
    return nil;
}

- (void)moveBefore:(SCNode *)aNode
{
    OSCMessage *message = [[self class] n_beforeMessageWithSourceNodeID:self.nodeID targetNodeID:aNode.nodeID];
    [SCBundle sendMessage:message];
}

- (void)moveAfter:(SCNode *)aNode
{
    OSCMessage *message = [[self class] n_afterMessageWithSourceNodeID:self.nodeID targetNodeID:aNode.nodeID];
    [SCBundle sendMessage:message];
}

- (void)free
{
    OSCMessage *message = [[self class] n_freeMessageWithNodeID:self.nodeID];
    [SCBundle sendMessage:message];
}

- (void)releaseWithGate
{
    if (self.hasGate) 
    {
        NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"gate"];
        OSCMessage *message = [[self class] n_setMessageWithNodeID:self.nodeID 
                                                      andArguments:[args sc_asOSCArgsArray]];
        [SCBundle sendMessage:message];
    }
    else
    {
        [self free];
    }
}

- (void)completionBlock:(SCNodeCompletionBlock)completionBlock
{
    if (completionObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:completionObserver];
        completionObserver = nil;
    }
    
    if (completionBlock) 
    {
        __weak SCNode *weakSelf = self;
        completionObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SCServerNodeDidEndNotification 
                                                                               object:nil 
                                                                                queue:[NSOperationQueue mainQueue] 
                                                                           usingBlock:^(NSNotification *note) 
                              {
                                  NSNumber *endedNodeID = [[note userInfo] objectForKey:SCServerNodeIDKey];
                                  if ([endedNodeID integerValue] == self.nodeID)
                                  {
                                      completionBlock();
                                      [weakSelf cleanupCompletionObserver];
                                  }
                              }];
    }
}

- (void)cleanupCompletionObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:completionObserver];
    completionObserver = nil;
}

#pragma mark - Message Creation

+ (OSCMessage *)n_setMessageWithNodeID:(SCNodeID)nodeID
                          andArguments:(NSArray *)arguments
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/n_set"];
    
    [message addValue:[OSCValue createWithInt:nodeID]];
    
    [message addArguments:arguments];
    
    return message;
}

+ (OSCMessage *)n_mapMessageWithNodeID:(SCNodeID)nodeID
                           controlName:(NSString *)controlName
                                 busID:(SCBusID)busID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/n_map"];
    [message addInt:nodeID];
    [message addString:controlName];
    [message addInt:busID];
    return message;
}

+ (OSCMessage *)n_mapaMessageWithNodeID:(SCNodeID)nodeID
                            controlName:(NSString *)controlName
                                  busID:(SCBusID)busID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/n_mapa"];
    [message addInt:nodeID];
    [message addString:controlName];
    [message addInt:busID];
    return message;
}

+ (OSCMessage *)n_freeMessageWithNodeID:(SCNodeID)nodeID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/n_free"];
    [message addInt:nodeID];
    return message;
}

+ (OSCMessage *)n_beforeMessageWithSourceNodeID:(SCNodeID)sourceNodeID
                                   targetNodeID:(SCNodeID)targetNodeID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/n_before"];
    [message addInt:sourceNodeID];
    [message addInt:targetNodeID];
    return message;
}

+ (OSCMessage *)n_afterMessageWithSourceNodeID:(SCNodeID)sourceNodeID
                                  targetNodeID:(SCNodeID)targetNodeID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/n_after"];
    [message addInt:sourceNodeID];
    [message addInt:targetNodeID];
    return message;
}

+ (NSString *)descriptionForAddAction:(SCAddAction)addAction
{
    NSString *addActionName = nil;
    switch (addAction) {
        case SCAddBeforeAction:
            addActionName = @"before";
            break;
        case SCAddAfterAction:
            addActionName = @"after";
            break;
        case SCAddToHeadAction:
            addActionName = @"head";
            break;
        case SCAddToTailAction:
            addActionName = @"tail";
            break;
        default:
            break;
    }
    return addActionName;
}


@end
