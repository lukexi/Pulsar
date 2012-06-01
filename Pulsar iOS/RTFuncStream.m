//
//  SCFuncStream.m
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "RTFuncStream.h"

@implementation RTFuncStream
{
    RTFuncStreamFunc _func;
}

+ (RTFuncStream *)funcStreamWithFunc:(RTFuncStreamFunc)func
{
    return [[self alloc] initWithFunc:func];
}

- (id)initWithFunc:(RTFuncStreamFunc)func
{
    self = [super init];
    if (self)
    {
        _func = func;
    }
    return self;
}

- (id)rt_next
{
    return [self rt_next:nil];
}

- (id)rt_next:(id)inValue
{
    return _func(inValue);
}

@end
