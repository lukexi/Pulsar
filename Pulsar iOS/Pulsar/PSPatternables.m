//
//  PSPatternables.m
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSPatternables.h"

@implementation NSObject (Patternable)

- (PSPattern *)asPattern
{
    return [PSListPattern listPatternWithValues:@[self]];
}

@end

@implementation NSArray (Patternable)

- (PSPattern *)asPattern
{
    return [PSListPattern listPatternWithValues:self];
}

@end

@implementation NSOrderedSet (Patternable)

- (PSPattern *)asPattern
{
    return [PSListPattern listPatternWithValues:[[self array] copy]];
}

@end

@implementation NSSet (Patternable)

- (PSPattern *)asPattern
{
    return [PSListPattern listPatternWithValues:[self allObjects]];
}

@end