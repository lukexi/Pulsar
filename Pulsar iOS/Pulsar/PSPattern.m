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

+ (id)patternWithValues:(NSArray *)values
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

- (PSStream *)asStream
{
    return [PSStream streamWithPattern:self];
}

- (PSPattern *)asPattern
{
    return self;
}

@end
