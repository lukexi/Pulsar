//
//  SCNode.h
//  Artikulator
//
//  Created by Luke Iannini on 6/26/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCServer.h"
#import "SCBundle.h"
#import "VVOSC.h"
#import "OSCMessage+AddArguments.h"

typedef void(^SCNodeCompletionBlock)(void);

@interface SCNode : NSObject
{
    SCNodeID nodeID;
}

@property (nonatomic) SCNodeID nodeID;
@property (nonatomic, strong) SCNode *target;
@property (nonatomic) SCAddAction addAction;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL hasGate;

- (void)send;
- (OSCMessage *)message;

- (void)moveBefore:(SCNode *)aNode;
- (void)moveAfter:(SCNode *)aNode;

- (void)free;
- (void)releaseWithGate;

- (void)completionBlock:(SCNodeCompletionBlock)completionBlock;

#pragma mark - Message Creation

+ (OSCMessage *)n_setMessageWithNodeID:(SCNodeID)nodeID
                          andArguments:(NSArray *)arguments;

+ (OSCMessage *)n_mapMessageWithNodeID:(SCNodeID)nodeID
                           controlName:(NSString *)controlName
                                 busID:(SCBusID)busID;

+ (OSCMessage *)n_mapaMessageWithNodeID:(SCNodeID)nodeID
                            controlName:(NSString *)controlName
                                  busID:(SCBusID)busID;

+ (OSCMessage *)n_freeMessageWithNodeID:(SCNodeID)nodeID;

+ (OSCMessage *)n_beforeMessageWithSourceNodeID:(SCNodeID)sourceNodeID
                                   targetNodeID:(SCNodeID)targetNodeID;

+ (OSCMessage *)n_afterMessageWithSourceNodeID:(SCNodeID)sourceNodeID
                                  targetNodeID:(SCNodeID)targetNodeID;

+ (NSString *)descriptionForAddAction:(SCAddAction)addAction;

@end
