//
//  PSBlock.m
//  Pulsar
//
//  Created by Luke Iannini on 4/6/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSBlock.h"

@interface PSBlock ()
@property (nonatomic, copy) PSEventTransformerBlock block;
@end

@implementation PSBlock

+ (PSBlock *)block:(PSEventTransformerBlock)block
{
    return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(PSEventTransformerBlock)block
{
    self = [super init];
    if (self)
    {
        _block = [block copy];
    }
    return self;
}

- (id)evaluate:(NSDictionary *)event
{
    return self.block(event);
}

@end
