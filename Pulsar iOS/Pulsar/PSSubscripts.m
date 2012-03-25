//
//  PSSubscripts.m
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSSubscripts.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_5_1

@implementation NSDictionary (Subscripts)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

@end

@implementation NSMutableDictionary (Subscripts)

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    [self setObject:obj forKey:key];
}

@end

@implementation NSArray (Subscripts)

- (id)objectAtIndexedSubscript:(NSInteger)idx
{
    return [self objectAtIndex:idx];
}

@end

@implementation NSMutableArray (Subscripts)

- (void)setObject:(id)obj atIndexedSubscript:(NSInteger)idx
{
    [self replaceObjectAtIndex:idx withObject:obj];
}

@end

#endif