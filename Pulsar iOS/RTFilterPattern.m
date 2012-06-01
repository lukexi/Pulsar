//
//  RTFilterPattern.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTFilterPattern.h"

@implementation RTFilterPattern

@end

@implementation RTPn

+ (RTPn *)PnWithPattern:(RTPattern *)pattern repeats:(id)repeats
{
    RTPn *pn = [[self alloc] init];
    pn.pattern = pattern;
    pn.repeats = repeats;
    return pn;
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id localInValue = inValue;
    
    id repeatsValue = [self.repeats rt_value:inValue];
    [repeatsValue rt_do:^(id inValue) {
        localInValue = [self.pattern embedInStream:yield inValue:localInValue];
    }];
    return localInValue;
}

@end

@implementation RTPStutter

+ (RTPStutter *)PStutterWithPattern:(RTPattern *)pattern n:(id)n
{
    RTPStutter *stutter = [[self alloc] init];
    stutter.pattern = pattern;
    stutter.n = n;
    return stutter;
}
/*
 embedInStream { arg event;
 var inevent, nn;
 
 var stream = pattern.asStream;
 var nstream = n.asStream;
 
 while {
     (inevent = stream.next(event)).notNil
 } {
     if((nn = nstream.next(event)).notNil) {
         nn.abs.do {
             event = inevent.copy.yield;
         };
     } { ^event };
 };
 ^event;
 }
*/
- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id localInValue = inValue;
    id nextPatternValue, nextN;
    
    id patternStream = [self.pattern rt_asStream];
    id nStream = [self.n rt_asStream];
    
    while ((nextPatternValue = [patternStream rt_next:localInValue]))
    {
        if ((nextN = [nStream rt_next:localInValue]))
        {
            [[nextN rt_abs] rt_do:^(id inValue) {
                localInValue = yield([nextPatternValue copy]);
            }];
        }
        else
        {
            return localInValue;
        }
    }
    return localInValue;
}

@end