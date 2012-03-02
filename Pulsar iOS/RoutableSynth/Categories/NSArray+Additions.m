//
//  NSArray+Additions.m
//  Artikulator
//
//  Created by Luke Iannini on 8/16/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

+ (NSArray *)lx_arrayWithIntegers:(NSInteger[])integers length:(size_t)length
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger index = 0; index < length; index++) 
    {
        NSInteger integer = integers[index];
        [array addObject:[NSNumber numberWithInteger:integer]];
    }
    return array;
}

+ (NSArray *)lx_arrayWithCGFloats:(CGFloat[])floats length:(size_t)length
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger index = 0; index < length; index++) 
    {
        CGFloat aFloat = floats[index];
        [array addObject:[NSNumber numberWithFloat:aFloat]];
    }
    return array;
}

+ (NSArray *)lx_arrayWithFloats:(float[])floats length:(size_t)length
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger index = 0; index < length; index++) 
    {
        float aFloat = floats[index];
        [array addObject:[NSNumber numberWithFloat:aFloat]];
    }
    return array;
}

@end
