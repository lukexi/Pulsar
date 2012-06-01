//
//  RTStream.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTStream.h"

@implementation RTStream

#pragma mark - RTEmbedInStream
// Iterate through each value of this Routine, passing it the relvant inValue
// and then yielding it to the parent Routine, and collecting the inValue
// from that yield to then pass into ourselves again. When we finally return
// nil, we return control to the parent routine along with the latest inValue
// we got from its yield.
- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    id outValue;
    while ((outValue = [self rt_next:inValue]))
    {
        inValue = yield(outValue);
    }
    
    return inValue;
}

- (id)rt_value
{
    return [self rt_value];
}

- (id)rt_value:(id)inValue
{
    return [self rt_next:inValue];
}

#pragma mark - RTDo
- (void)rt_do:(RTDoFunction)function
{
    id outValue;
    while ((outValue = [self rt_next]))
    {
        function(outValue);
    }
}

- (id)rt_next:(id)inValue
{
    NSAssert(NO, @"Must implement in subclass");
    return nil;
}

- (id)rt_next
{
    NSAssert(NO, @"Must implement in subclass");
    return nil;
}

- (NSArray *)nextN:(NSUInteger)nextN
{
    NSMutableArray *nextNValues = [NSMutableArray arrayWithCapacity:nextN];
    for (NSUInteger i = 0; i < nextN; i++)
    {
        id next = [self rt_next];
        if (next)
        {
            [nextNValues addObject:next];
        }
    }
    return nextNValues;
}

@end
