//
//  PSPattern.m
//  PSPattern
//
//  Created by Luke Iannini on 3/24/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSPattern.h"
#import "PSStream.h"

@implementation PSPattern

+ (id)pattern
{
    return [[self alloc] init];
}

- (NSArray *)embedInStream
{
    return nil;
}

- (PSStream *)asStream
{
    return [PSStream streamWithPattern:self];
}

- (PSPattern *)asPattern
{
    return self;
}

@end

@implementation PSListPattern

+ (id)listPatternWithValues:(NSArray *)values
{
    return [[self alloc] initWithValues:values];
}

- (id)initWithValues:(NSArray *)theValues
{
    self = [super init];
    if (self)
    {
        _values = theValues;
    }
    return self;
}

- (NSArray *)embedInStream
{
    return self.values;
}

@end

@implementation PSBlockPattern

+ (id)blockPatternWithBlock:(id)block
{
    return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(id)block
{
    self = [super init];
    if (self)
    {
        _block = [block copy];
    }
    return self;
}

- (NSArray *)embedInStream
{
    return @[self.block];
}

@end

@implementation PSWhite

+ (id)between:(CGFloat)lowValue and:(CGFloat)highValue
{
    return [[self alloc] initWithLow:lowValue high:highValue];
}

- (id)initWithLow:(CGFloat)lowValue high:(CGFloat)highValue
{
    self = [super init];
    if (self)
    {
        _lowValue = lowValue;
        _highValue = highValue;
    }
    return self;
}

- (NSArray *)embedInStream
{
    CGFloat range = self.highValue - self.lowValue;
    CGFloat rangeScaled = (CGFloat)arc4random() / 0x100000000 * range;
    return @[[NSNumber numberWithFloat:(self.lowValue + rangeScaled)]];
}

@end

@implementation PSEvery

+ (id)every:(NSUInteger)times apply:(PSFilterPattern *)filterPattern
{
    return [[self alloc] initWithEvery:times apply:filterPattern];
}

- (id)initWithEvery:(NSUInteger)times apply:(PSFilterPattern *)filterPattern
{
    self = [super init];
    if (self)
    {
        _every = times;
        _filter = filterPattern;
    }
    return self;
}

- (NSArray *)embedInStream
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.every; i++)
    {
        if (i == self.every - 1)
        {
            [array addObjectsFromArray:[self.filter filteredValues]];
        }
        else
        {
            [array addObjectsFromArray:self.filter.listPattern.values];
        }
    }
    return array;
}

@end

@implementation PSFilterPattern

- (id)initWithListPattern:(PSListPattern *)listPattern
{
    self = [super init];
    if (self)
    {
        _listPattern = listPattern;
    }
    return self;
}

- (NSArray *)embedInStream
{
    return [self filteredValues];
}

- (NSArray *)filteredValues
{
    return self.listPattern.values;
}

@end

@implementation PSRotate

+ (PSRotate *)rotate:(PSListPattern *)listPattern places:(NSInteger)places
{
    return [[self alloc] initWithListPattern:listPattern places:places];
}

- (id)initWithListPattern:(PSListPattern *)listPattern places:(NSUInteger)places
{
    self = [super initWithListPattern:listPattern];
    if (self)
    {
        _places = places;
    }
    return self;
}

- (NSArray *)filteredValues
{
    NSMutableArray *mutableValues = [self.listPattern.values mutableCopy];
    NSUInteger absPlaces = abs(self.places);
    if (self.places < 0)
    {
        for (NSUInteger i = 0; i < absPlaces; i++) 
        {
            id firstObject = [mutableValues objectAtIndex:0];
            [mutableValues removeObjectAtIndex:0];
            [mutableValues addObject:firstObject];
        }
    }
    else
    {
        for (NSUInteger i = 0; i < absPlaces; i++) 
        {
            id lastObject = [mutableValues lastObject];
            [mutableValues removeLastObject];
            [mutableValues insertObject:lastObject atIndex:0];
        }
    }
    return mutableValues;
}

@end

@implementation PSScramble

+ (PSScramble *)scramble:(PSListPattern *)listPattern
{
    return [[self alloc] initWithListPattern:listPattern];
}

- (NSArray *)filteredValues
{
    NSMutableArray *newValues = [NSMutableArray arrayWithCapacity:[self.listPattern.values count]];
    
    NSMutableArray *remainingValues = [self.listPattern.values mutableCopy];
    while ([remainingValues count])
    {
        NSUInteger randomIndex = arc4random() % [remainingValues count];
        [newValues addObject:[remainingValues objectAtIndex:randomIndex]];
        [remainingValues removeObjectAtIndex:randomIndex];
    }
    return newValues;
}

@end

@implementation PSReverse

+ (PSReverse *)reverse:(PSListPattern *)listPattern
{
    return [[self alloc] initWithListPattern:listPattern];
}

- (NSArray *)filteredValues
{
    NSMutableArray *newValues = [NSMutableArray arrayWithCapacity:[self.listPattern.values count]];
    NSEnumerator *reverseEnumerator = [self.listPattern.values reverseObjectEnumerator];
    
    for (NSUInteger i = 0; i < [self.listPattern.values count]; i++)
    {
        [newValues addObject:[reverseEnumerator nextObject]];
    }
    return newValues;
}
@end