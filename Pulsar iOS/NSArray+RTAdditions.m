//
//  NSArray+RTAdditions.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "NSArray+RTAdditions.h"
#import "NSNumber+RTDo.h"

@implementation NSArray (RTAdditions)

- (id)rt_wrapObjectAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index % [self count]];
}

- (id)rt_choose
{
    return [self objectAtIndex:arc4random_uniform([self count])];
}

- (NSArray *)rt_scramble
{
    NSMutableArray *mutableCopy = [self mutableCopy];
    for (NSUInteger i = 0; i < [mutableCopy count]; i++)
    {
        NSUInteger randomIndex = arc4random_uniform([mutableCopy count] - i) + i;
        [mutableCopy exchangeObjectAtIndex:i withObjectAtIndex:randomIndex];
    }
    return mutableCopy;
}

- (CGFloat)rt_floatSum
{
    CGFloat sum = 0;
    for (NSNumber *number in self)
    {
        sum += [number floatValue];
    }
    return sum;
}

- (NSInteger)rt_integerSum
{
    NSInteger sum = 0;
    for (NSNumber *number in self)
    {
        sum += [number integerValue];
    }
    return sum;
}

@end


@implementation NSArray (EnumeratePairs)

- (void)ps_enumeratePairs:(PSArrayPairsBlock)block
{
    NSAssert([self count] % 2 == 0, @"Must have an even number of elements to collect pairs");
    for (NSUInteger leftIndex = 0, rightIndex = 1;
         leftIndex < ([self count]);
         leftIndex+=2, rightIndex+=2)
    {
        id left = [self objectAtIndex:leftIndex];
        id right = [self objectAtIndex:rightIndex];
        block(left, right);
    }
}

- (NSArray *)ps_collectPairs:(PSCollectPairsBlock)block
{
    NSMutableArray *collected = [NSMutableArray arrayWithCapacity:
                                 [self count]];
    
    [self ps_enumeratePairs:^(id left, id right){
        NSArray *newPair = block(left, right);
        [collected addObjectsFromArray:newPair];
    }];
    
    return collected;
}

- (NSDictionary *)ps_collectPairsAsDictionary:(PSCollectPairsBlock)block
{
    NSMutableDictionary *collected = [NSMutableDictionary dictionaryWithCapacity:
                                      [self count] / 2];
    [self ps_enumeratePairs:^(id left, id right){
        NSArray *newPair = block(left, right);
        [collected setObject:[newPair objectAtIndex:1] forKey:[newPair objectAtIndex:0]];
    }];
    return collected;
}

@end

@implementation NSArray (Generators)

+ (NSArray *)rt_generatedRhythmFillingBeatCount:(NSUInteger)beatCount
                                  paddedToBeats:(BOOL)paddedToBeats
                                    minExponent:(NSInteger)minExponent
                                    maxExponent:(NSInteger)maxExponent
{
    NSUInteger possibleDurationsCount = maxExponent - minExponent;
    NSMutableArray *possibleDurations = [NSMutableArray arrayWithCapacity:possibleDurationsCount];
    
    for (NSUInteger i = 0; i < possibleDurationsCount; i++)
    {
        [possibleDurations addObject:[NSNumber numberWithFloat:1/powf(2, i+minExponent)]];
    }
    
    NSMutableArray *durations = [NSMutableArray array];
    CGFloat nextDuration = [[possibleDurations rt_choose] floatValue];
    while (([durations rt_floatSum] + nextDuration) < beatCount)
    {
        [durations addObject:[NSNumber numberWithFloat:nextDuration]];
        nextDuration = [[possibleDurations rt_choose] floatValue];
    }
    if (paddedToBeats)
    {
        [durations addObject:[NSNumber numberWithFloat:beatCount - [durations rt_floatSum]]];
    }
    return durations;
}

+ (NSArray *)rt_generatedChordProgressionWithLength:(NSUInteger)length
                                            repeats:(NSUInteger)repeats
{
    NSMutableArray *notes = [NSMutableArray array];
    for (NSUInteger i = 0; i < length; i++)
    {
        [notes addObject:[@12 rt_rand]];
    }
    
    NSMutableArray *progression = [NSMutableArray array];
    for (NSUInteger i = 0; i < repeats; i++)
    {
        [progression addObjectsFromArray:notes];
    }
    return progression;
}

@end