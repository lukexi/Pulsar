//
//  PSScale.m
//  Pulsar
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "PSScale.h"

@interface PSScale ()

@property (nonatomic, strong, readwrite) NSArray *degrees;

@end

@implementation PSScale

+ (PSScale *)scaleWithDegrees:(NSArray *)degrees
{
    return [[self alloc] initWithDegrees:degrees];
}

- (id)initWithDegrees:(NSArray *)theDegrees
{
    self = [super init];
    if (self) {
        _degrees = theDegrees;
    }
    return self;
}

- (NSUInteger)degreeAtIndex:(NSUInteger)index
{
    return [[self.degrees objectAtIndex:index] unsignedIntegerValue];
}

+ (PSScale *)majorScale
{
    return [PSScale scaleWithDegrees:@[@0, @2, @4, @5, @7, @9, @11]];
}

@end
