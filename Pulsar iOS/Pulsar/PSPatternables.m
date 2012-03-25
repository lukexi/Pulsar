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
    return [PSPattern patternWithValues:@[self]];
}

@end

@implementation NSArray (Patternable)

- (PSPattern *)asPattern
{
    return [PSPattern patternWithValues:self];
}

@end
