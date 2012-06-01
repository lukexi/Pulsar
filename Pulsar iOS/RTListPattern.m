//
//  RTListPattern.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTListPattern.h"
#import "NSArray+RTAdditions.h"
@implementation RTListPattern

+ (id)listPatternWithList:(NSArray *)list repeats:(id)repeats
{
    RTListPattern *listPattern = [[self alloc] init];
    listPattern.list = list;
    listPattern.repeats = repeats;
    return listPattern;
}

@end

@implementation RTPSeq

+ (id)PSeqWithList:(NSArray *)list repeats:(id)repeats
{
    return [self PSeqWithList:list repeats:repeats offset:@0];
}
+ (id)PSeqWithList:(NSArray *)list repeats:(id)repeats offset:(id)offset
{
    RTPSeq *seq = [self listPatternWithList:list repeats:repeats];
    seq.offset = offset;
    return seq;
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id item;
    NSInteger offsetValue = [[self.offset rt_value] integerValue];
    
    [[self.repeats rt_value:inValue] rt_do:^(id inValue) {
        __block NSUInteger index = 0;
        [[NSNumber numberWithUnsignedInteger:[self.list count]] rt_do:^(id inValue) {
            item = [self.list rt_wrapObjectAtIndex:index + offsetValue];
            inValue = [item embedInStream:yield inValue:inValue];
            index++;
        }];
    }];
    return inValue;
}

@end

@implementation RTPShuf

+ (id)PShufWithList:(NSArray *)list repeats:(id)repeats
{
    return [self listPatternWithList:list repeats:repeats];
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id item;
    __block id localInValue = inValue;
    NSArray *scrambled = [self.list rt_scramble];
    
    [[self.repeats rt_value:inValue] rt_do:^(id inValue) {
        __block NSUInteger index = 0;
        [[NSNumber numberWithUnsignedInteger:[scrambled count]] rt_do:^(id inValue) {
            item = [scrambled rt_wrapObjectAtIndex:index];
            localInValue = [item embedInStream:yield inValue:inValue];
            index++;
        }];
    }];
    return localInValue;
}

@end

@implementation RTPRand

+ (id)PRandWithList:(NSArray *)list repeats:(id)repeats
{
    return [self listPatternWithList:list repeats:repeats];
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    __block id item;
    __block id localInValue = inValue;
    [[self.repeats rt_value:inValue] rt_do:^(id inValue) {
        item = [self.list rt_choose];
        localInValue = [item embedInStream:yield inValue:inValue];
    }];
    return localInValue;
}

@end

