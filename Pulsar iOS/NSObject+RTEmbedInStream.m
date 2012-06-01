//
//  NSObject+RTEmbedInStream.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "NSObject+RTEmbedInStream.h"

@implementation NSObject (RTEmbedInStream)

- (id)rt_value:(id)inValue
{
    return self;
}

- (id)rt_value
{
    return self;
}

- (id)rt_next:(id)inValue
{
    return self;
}

- (id)rt_next
{
    return self;
}

- (id)rt_asStream
{
    return self;
}

- (id)embedInStream:(RTYieldBlock)yield inValue:(id)inValue
{
    return yield(self);
}

@end
