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

@implementation PSEvery

+ (id)every:(NSUInteger)times apply:(PSFilterPattern *)filterPattern to:(PSListPattern *)listPattern
{
    return [[self alloc] initWithEvery:times apply:filterPattern to:listPattern];
}

- (id)initWithEvery:(NSUInteger)times apply:(PSFilterPattern *)filterPattern to:(PSListPattern *)listPattern
{
    self = [super init];
    if (self)
    {
        _every = times;
        _filter = filterPattern;
        _listPattern = listPattern;
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
            NSArray *filteredValues = [self.filter filter:self.listPattern];
            [array addObjectsFromArray:filteredValues];
        }
        else
        {
            [array addObjectsFromArray:self.listPattern.values];
        }
    }
    return array;
}

@end

@implementation PSFilterPattern

- (NSArray *)filter:(PSListPattern *)listPattern
{
    return listPattern.values;
}

@end

@implementation PSRotate

+ (PSRotate *)rotate:(NSInteger)places
{
    return [[self alloc] initWithPlaces:places];
}

- (id)initWithPlaces:(NSUInteger)places
{
    self = [super init];
    if (self)
    {
        _places = places;
    }
    return self;
}

- (NSArray *)filter:(PSListPattern *)listPattern
{
    NSMutableArray *mutableValues = [listPattern.values mutableCopy];
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

+ (PSScramble *)scramble
{
    return [[self alloc] init];
}

- (NSArray *)filter:(PSListPattern *)listPattern
{
    NSMutableArray *newValues = [NSMutableArray arrayWithCapacity:[listPattern.values count]];
    
    NSMutableArray *remainingValues = [listPattern.values mutableCopy];
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

+ (PSReverse *)reverse
{
    return [[self alloc] init];
}

- (NSArray *)filter:(PSListPattern *)listPattern
{
    NSMutableArray *newValues = [NSMutableArray arrayWithCapacity:[listPattern.values count]];
    NSEnumerator *reverseEnumerator = [listPattern.values reverseObjectEnumerator];
    
    for (NSUInteger i = 0; i < [listPattern.values count]; i++)
    {
        [newValues addObject:[reverseEnumerator nextObject]];
    }
    return newValues;
}
@end