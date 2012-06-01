//
//  SCPattern.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTRoutine.h"
#import "RTFuncStream.h"
#import "RTEventStreamPlayer.h"

#define RTInf [NSNumber numberWithInteger:INFINITY]

@interface RTPattern : NSObject <RTEmbedInStream>

@end

@interface RTPFunc : RTPattern

+ (RTPFunc *)PFunc:(RTFuncStreamFunc)func;

@end

@interface RTPBrown : RTPattern

+ (RTPBrown *)PBrownWithLow:(id)low high:(id)high step:(id)step length:(id)length;
@property (nonatomic, strong) id low;
@property (nonatomic, strong) id high;
@property (nonatomic, strong) id step;
@property (nonatomic, strong) id length;

@end

@interface RTPWhite : RTPattern

+ (RTPWhite *)PWhiteWithLow:(id)low high:(id)high length:(id)length;
@property (nonatomic, strong) id low;
@property (nonatomic, strong) id high;
@property (nonatomic, strong) id length;

@end

@interface RTPLazy : RTPattern

+ (RTPLazy *)PLazyWithFunc:(RTFuncStreamFunc)func;
@property (nonatomic, strong) RTFuncStreamFunc func;

@end

@interface RTPBind : RTPattern

+ (RTPBind *)PBindWithPairs:(NSArray *)patternPairs;
// You must pass in a prototype dictionary when calling next: on RTPBind
@property (nonatomic, strong) NSArray *patternPairs;

- (RTEventStreamPlayer *)play:(NSArray *)blocks;
- (RTEventStreamPlayer *)play:(NSArray *)blocks withPrototypeEvent:(NSDictionary *)prototypeEvent;

@end