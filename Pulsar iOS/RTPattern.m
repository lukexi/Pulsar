//
//  SCPattern.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTPattern.h"
#import "NSNumber+RTDo.h"
#import "NSArray+RTAdditions.h"
#import "RTEventStreamPlayer.h"

@implementation RTPattern

- (RTRoutine *)rt_asStream
{
    return [RTRoutine routineWithBlock:^(RTYieldBlock yield, id inValue) {
        [self embedInStream:yield inValue:inValue];
    }];
}

#pragma mark - RTEmbedInStream
- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    return [[self rt_asStream] embedInStream:yield inValue:inValue];
}

@end

@implementation RTPFunc
{
    RTFuncStreamFunc _func;
}

+ (RTPFunc *)PFunc:(RTFuncStreamFunc)func
{
    return [[self alloc] initWithPFunc:func];
}

- (id)initWithPFunc:(RTFuncStreamFunc)func
{
    self = [super init];
    if (self) {
        _func = func;
    }
    return self;
}

- (RTFuncStream *)rt_asStream
{
    return [RTFuncStream funcStreamWithFunc:_func];
}

@end


@implementation RTPBrown

+ (RTPBrown *)PBrownWithLow:(id)low high:(id)high step:(id)step length:(id)length
{
    RTPBrown *brown = [[self alloc] init];
    brown.low = low;
    brown.high = high;
    brown.step = step;
    brown.length = length;
    return brown;
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id localInValue = inValue;
    __block id currentValue, lowValue, highValue, stepValue;
    id lowStream, highStream, stepStream;
    lowStream = [self.low rt_asStream];
    highStream = [self.high rt_asStream];
    stepStream = [self.step rt_asStream];
    
    lowValue = [lowStream rt_next:inValue];
    highValue = [highStream rt_next:inValue];
    stepValue = [stepStream rt_next:inValue];
    
    currentValue = [lowValue rt_rangedRandAsLowWithHigh:highValue];
    if (!lowValue || !highValue || !stepValue)
    {
        return inValue;
    }
    
    [[self.length rt_value:inValue] rt_do:^(id inValue) {
        lowValue = [lowStream rt_next:inValue];
        highValue = [highStream rt_next:inValue];
        stepValue = [stepStream rt_next:inValue];
        if (!lowValue || !highValue || !stepValue)
        {
            return;
        }
        currentValue = [[self calcNext:currentValue step:stepValue] rt_foldLow:lowValue high:highValue];
        localInValue = yield(currentValue);
    }];
    
    return localInValue;
}

- (NSNumber *)calcNext:(NSNumber *)current step:(NSNumber *)step
{
    if ([current rt_isFloat])
    {
        CGFloat result = [current floatValue] + [[step rt_xrand2Excluding:nil] floatValue];
        return [NSNumber numberWithFloat:result];
    }
    NSInteger result = [current integerValue] + [[step rt_xrand2Excluding:nil] integerValue];
    return [NSNumber numberWithInteger:result];
}

@end

@implementation RTPWhite

+ (RTPWhite *)PWhiteWithLow:(id)low high:(id)high length:(id)length
{
    RTPWhite *white = [[self alloc] init];
    white.low = low;
    white.high = high;
    white.length = length;
    return white;
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id localInValue = inValue;
    __block id lowValue, highValue;
    id lowStream, highStream;
    
    lowStream = [self.low rt_asStream];
    highStream = [self.high rt_asStream];
    
    [[self.length rt_value:inValue] rt_do:^(id inValue) {
        lowValue = [lowStream rt_next:localInValue];
        highValue = [highStream rt_next:localInValue];
        if (!lowValue || !highValue)
        {
            return;
        }
        
        localInValue = yield([lowValue rt_rangedRandAsLowWithHigh:highValue]);
    }];
    
    return localInValue;
}

@end

@implementation RTPLazy

+ (RTPLazy *)PLazyWithFunc:(RTFuncStreamFunc)func
{
    RTPLazy *lazy = [[self alloc] init];
    lazy.func = func;
    return lazy;
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    return [self.func(inValue) embedInStream:yield inValue:inValue];
}

@end

@implementation RTPBind

+ (RTPBind *)PBindWithPairs:(NSArray *)patternPairs
{
    RTPBind *pBind = [[self alloc] init];
    pBind.patternPairs = patternPairs;
    return pBind;
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id localInValue = inValue;
    NSArray *streamPairs = [self.patternPairs ps_collectPairs:^NSArray *(id left, id right) {
        return @[left, [right rt_asStream]];
    }];
    
    __block BOOL sawNil = NO;
    
    while (localInValue)
    {
        NSDictionary *prototypeEvent = localInValue;
        NSMutableDictionary *event = [prototypeEvent mutableCopy];
        [streamPairs ps_enumeratePairs:^(id left, id right) {
            id nextValueForKey = [right rt_next:event];
            if (nextValueForKey)
            {
                [event setObject:nextValueForKey forKey:left];
            }
            else
            {
                NSLog(@"Event hit nil for key: %@", left);
                sawNil = YES;
            }
        }];
        if (sawNil)
        {
            break;
        }
        localInValue = yield(event);
    }
    return yield(nil);
}

- (RTEventStreamPlayer *)play:(NSArray *)blocks withPrototypeEvent:(NSDictionary *)prototypeEvent
{
    RTEventStreamPlayer *eventStreamPlayer = [RTEventStreamPlayer eventStreamPlayerWithStream:[self rt_asStream]
                                                                                       blocks:blocks];
    eventStreamPlayer.prototypeEvent = prototypeEvent;
    [eventStreamPlayer play];
    return eventStreamPlayer;
}

- (RTEventStreamPlayer *)play:(NSArray *)blocks
{
    RTEventStreamPlayer *eventStreamPlayer = [RTEventStreamPlayer eventStreamPlayerWithStream:[self rt_asStream]
                                                                                       blocks:blocks];
    [eventStreamPlayer play];
    return eventStreamPlayer;
}

@end