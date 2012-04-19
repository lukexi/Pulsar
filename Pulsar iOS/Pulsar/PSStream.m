//
//  PSStream.m
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSStream.h"
#import "PSPattern.h"

@implementation PSStream
{
    PSPattern *pattern;
    NSEnumerator *currentEnumerator;
}

+ (PSStream *)streamWithPattern:(PSPattern *)pattern
{
    return [[self alloc] initWithPattern:pattern];
}

- (id)initWithPattern:(PSPattern *)aPattern
{
    self = [super init];
    if (self)
    {
        pattern = aPattern;
    }
    return self;
}

- (id)next
{
    id object = [currentEnumerator nextObject];
    if (!object)
    {
        currentEnumerator = [[pattern embedInStream] objectEnumerator];
        object = [currentEnumerator nextObject];
    }
    return object;
}

@end
