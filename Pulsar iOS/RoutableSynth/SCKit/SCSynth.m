//
//  SCSynth.m
//  Artikulator
//
//  Created by Luke Iannini on 6/25/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCSynth.h"
#import "SCBus.h"


@interface SCSynth ()

- (OSCMessage *)mapMessageForControlName:(NSString *)controlName bus:(SCBus *)bus;

@end

@implementation SCSynth
@synthesize name, arguments;


// TODO: figure out an SCKit convention for sending now vs sending later...
// maybe a blocks-and-class-variable based approach where synth messages can be collected, unsent?
+ (SCSynth *)synthWithName:(NSString *)synthName 
                 arguments:(NSArray *)arguments
                   sentNow:(BOOL)sendNow
{
    SCSynth *synth = [[self alloc] init];
    synth.name = synthName;
    synth.arguments = arguments;
    //DLog(@"Creating synth: %@ with args:%@", synthName, arguments);
    if (sendNow) 
    {
        [synth send];
    }
    return synth;
}

+ (SCSynth *)synthWithName:(NSString *)synthName 
                 arguments:(NSArray *)arguments 
{
    return [self synthWithName:synthName 
                     arguments:arguments 
                       sentNow:NO];
}

- (void)send
{
    //DLog(@"sending synth %@", [self message]);
    [SCBundle sendMessage:[self message]];
}

- (void)set:(NSArray *)someArguments
{
    OSCMessage *message = [[self class] n_setMessageWithNodeID:self.nodeID 
                                                  andArguments:someArguments];
    //NSLog(@"Sending %@", message);
    // TODO: sendmessageinbundle uses the default server sync delay, is that always wanted? 
    [SCBundle sendMessage:message];
}

- (void)map:(NSString *)controlName toBus:(SCBus *)bus
{
    OSCMessage *message = [self mapMessageForControlName:controlName bus:bus];
    [SCBundle sendMessage:message];
}

- (void)unmap:(NSString *)controlName fromBus:(SCBus *)bus
{
    SCBus *unmapBus = [bus copy];
    unmapBus.busID = -1; // Mapping to busID -1 unmaps a bus.
    OSCMessage *message = [self mapMessageForControlName:controlName 
                                                     bus:unmapBus];
    [SCBundle sendMessage:message];
}

- (OSCMessage *)mapMessageForControlName:(NSString *)controlName bus:(SCBus *)bus
{
    if (bus.rate == SCSynthControlRate) 
    {
        return [[self class] n_mapMessageWithNodeID:self.nodeID 
                                        controlName:controlName 
                                              busID:bus.busID];
    }
    else if (bus.rate == SCSynthAudioRate)
    {
        return [[self class] n_mapaMessageWithNodeID:self.nodeID 
                                         controlName:controlName 
                                               busID:bus.busID];
    }
    NSAssert2(NO, @"Unrecognized or unset bus rate:%i for bus: %@", bus.rate, bus);
    return nil;
}

- (SCNodeID)nodeID
{
    if (nodeID == 0)
    {
        self.nodeID = [[SCServer sharedServer] requestNodeID];
    }
    return nodeID;
}

- (OSCMessage *)message
{
    return [[self class] s_newMessageWithSynth:self.name 
                                  andArguments:self.arguments 
                                        nodeID:self.nodeID 
                                     addAction:self.addAction
                                  targetNodeID:self.target.nodeID];
}

#pragma mark - Message Creation

+ (OSCMessage *)s_newMessageWithSynth:(NSString *)synthName
                         andArguments:(NSArray *)arguments
                               nodeID:(SCNodeID)nodeID
{
    return [self s_newMessageWithSynth:synthName 
                          andArguments:arguments 
                                nodeID:nodeID 
                             addAction:SCAddToHeadAction 
                          targetNodeID:0];
}

+ (OSCMessage *)s_newMessageWithSynth:(NSString *)synthName
                         andArguments:(NSArray *)arguments
                               nodeID:(SCNodeID)nodeID
                            addAction:(SCAddAction)addAction
                         targetNodeID:(SCNodeID)targetNodeID
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/s_new"];
    [message addString:synthName];
    [message addInt:nodeID];
    [message addInt:addAction];
    [message addInt:targetNodeID];
    [message addArguments:arguments];
    return message;
}


@end
