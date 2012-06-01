//
//  NSNumber+RTDo.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "NSNumber+RTDo.h"

@implementation NSNumber (RTDo)

- (void)rt_do:(RTDoFunction)function
{
    for (NSUInteger i = 0; i < [self unsignedIntegerValue]; i++)
    {
        function([NSNumber numberWithUnsignedInteger:i]);
    }
}

- (NSArray *)rt_collect:(RTCollectFunction)function
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger i = 0; i < [self unsignedIntegerValue]; i++)
    {
        id result = function([NSNumber numberWithUnsignedInteger:i]);
        [array addObject:result];
    }
    return array;
}

@end

@implementation NSValue (TypeAdditions)

- (BOOL)rt_isIntegerType
{
    return strcmp([self objCType], @encode(int)) == 0 || 
    strcmp([self objCType], @encode(NSInteger)) == 0 || 
    strcmp([self objCType], @encode(NSUInteger)) == 0;
}

- (BOOL)rt_isFloatType
{
    return strcmp([self objCType], @encode(float)) == 0 || 
    strcmp([self objCType], @encode(double)) == 0 || 
    strcmp([self objCType], @encode(CGFloat)) == 0;
}

- (BOOL)rt_isBOOLType
{
    return strcmp([self objCType], @encode(BOOL)) == 0;
}

@end


@implementation NSNumber (RTAdditions)

- (BOOL)rt_isFloat
{
    return YES;
}

- (BOOL)rt_isInt
{
    return NO;
}

- (NSNumber *)rt_exprand:(NSNumber *)value2
{
    return [NSNumber numberWithFloat:exprandrng([self floatValue], [value2 floatValue])];
}

- (NSNumber *)rt_xrand2Excluding:(NSNumber *)exclude
{
    if ([self rt_isFloat])
    {
        return [NSNumber numberWithFloat:xrand2Float([self floatValue], [exclude floatValue])];
    }
    return [NSNumber numberWithInteger:xrand2Int([self integerValue], [exclude integerValue])];
}

- (NSNumber *)rt_foldLow:(NSNumber *)low high:(NSNumber *)high
{
    if ([self rt_isFloat])
    {
        return [NSNumber numberWithFloat:foldFloat([self floatValue], [low floatValue], [high floatValue])];
    }
    return [NSNumber numberWithInteger:foldInt([self integerValue], [low integerValue], [high integerValue])];
}

- (NSNumber *)rt_rand
{
    return [@0 rt_rangedRandAsLowWithHigh:self];
}

- (NSNumber *)rt_rangedRandAsLowWithHigh:(NSNumber *)high
{
    NSNumber *low = self;
    if ([self rt_isFloat])
    {
        CGFloat range = ([high floatValue] - [low floatValue]);
        CGFloat result = [low floatValue] + ((CGFloat)arc4random() / 0x100000000) * range;
        return [NSNumber numberWithFloat:result];
    }
    
    NSInteger range = [high integerValue] - [low integerValue];
    NSInteger result = [low integerValue] + arc4random_uniform(range);
    return [NSNumber numberWithInteger:result];
}

- (NSNumber *)rt_abs
{
    if ([self rt_isFloat])
    {
        return [NSNumber numberWithFloat:fabsf([self floatValue])];
    }
    return [NSNumber numberWithInteger:abs([self integerValue])];
}

@end

double exprandrng(double lo, double hi)
{
    double randomFloat = (CGFloat)arc4random() / 0x100000000;
	return lo * exp(log(hi / lo) * randomFloat);
}

CGFloat xrand2Float(CGFloat floatValue, CGFloat excludingValue)
{
    CGFloat randomFloat = (CGFloat)arc4random() / 0x100000000;
    CGFloat result = (randomFloat * 2.0 * floatValue) - floatValue;
    if (result == excludingValue)
    {
        return floatValue;
    }
    return result;
}

NSInteger xrand2Int(NSInteger intValue, NSInteger excludingValue)
{
    NSInteger result = arc4random_uniform(intValue * 2) - intValue;
    if (result == excludingValue)
    {
        return intValue;
    }
    return result;
}

NSInteger foldInt(NSInteger value, NSInteger low, NSInteger high)
{
    if (value > high)
    {
        return high - (value - high);
    }
    else if (value < low)
    {
        return low + (low - value);
    }
    return value;
}

CGFloat foldFloat(CGFloat value, CGFloat low, CGFloat high)
{
    if (value > high)
    {
        return high - (value - high);
    }
    else if (value < low)
    {
        return low + (low - value);
    }
    return value;
}