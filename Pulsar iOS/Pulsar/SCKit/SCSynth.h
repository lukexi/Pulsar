//
//  SCSynth.h
//  Artikulator
//
//  Created by Luke Iannini on 6/25/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNode.h"
#import "SCBus.h"

@interface SCSynth : SCNode

// By default, synths are returned "unsent" to the server so you can set additional properties or add their messages to a bundle
+ (SCSynth *)synthWithName:(NSString *)synthName 
                 arguments:(NSArray *)arguments;

// Use sentNow to send it immediately instead. Not terribly happy with this — see TODOs in the SCSynth.m file for an idea.
+ (SCSynth *)synthWithName:(NSString *)synthName 
                 arguments:(NSArray *)arguments
                   sentNow:(BOOL)sendNow;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *arguments;

- (void)set:(NSArray *)someArguments;
- (void)map:(NSString *)controlName toBus:(SCBus *)bus;
- (void)unmap:(NSString *)controlName fromBus:(SCBus *)bus;
- (void)send;
- (OSCMessage *)message;

#pragma mark - Message Creation

+ (OSCMessage *)s_newMessageWithSynth:(NSString *)synthName
                         andArguments:(NSArray *)arguments
                               nodeID:(SCNodeID)nodeID;

+ (OSCMessage *)s_newMessageWithSynth:(NSString *)synthName
                         andArguments:(NSArray *)arguments
                               nodeID:(SCNodeID)nodeID
                            addAction:(SCAddAction)addAction
                         targetNodeID:(SCNodeID)targetNodeID;

@end
