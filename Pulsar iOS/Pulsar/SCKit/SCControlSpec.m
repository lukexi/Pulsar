//
//  SCControlSpec.m
//  Artikulator
//
//  Created by Luke Iannini on 9/10/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCControlSpec.h"

@implementation SCControlSpec
@synthesize minValue, maxValue;
@synthesize warp, units;


+ (id)controlSpecWithMin:(CGFloat)min max:(CGFloat)max warpSpecifier:(NSString *)specifier units:(NSString *)units
{
    SCControlSpec *spec = [[self alloc] init];
    spec.minValue = min;
    spec.maxValue = max;
    spec.units = units;
    spec.warp = [[SCWarp warpClassForSpecifier:specifier] warpForSpec:spec];
    return spec;
}

- (CGFloat)map:(CGFloat)value
{
    return [self.warp map:value];
}

- (CGFloat)unmap:(CGFloat)value
{
    return [self.warp unmap:value];
}

- (CGFloat)range
{
    return self.maxValue - self.minValue;
}

- (CGFloat)ratio
{
    return self.maxValue / self.minValue;
}

@end


@implementation SCWarp
@synthesize spec;

+ (Class)warpClassForSpecifier:(NSString *)specifier
{
    static NSDictionary *classesBySpec = nil;
    if (!classesBySpec)
    {
        classesBySpec = [NSDictionary dictionaryWithObjectsAndKeys:
                         [SCLinearWarp class], @"lin",
                         [SCExponentialWarp class], @"exp",
                         [SCFaderWarp class], @"amp",
                          nil];
    }
    return [classesBySpec objectForKey:specifier];
}

+ (id)warpForSpec:(SCControlSpec *)spec
{
    SCWarp *warp = [[self alloc] init];
    warp.spec = spec;
    return warp;
}

- (CGFloat)map:(CGFloat)value
{
    return value;
}

- (CGFloat)unmap:(CGFloat)value
{
    return value;
}

@end

@implementation SCLinearWarp

- (CGFloat)map:(CGFloat)value
{
    return value * [self.spec range] + self.spec.minValue;
}

- (CGFloat)unmap:(CGFloat)value
{
    return (value - self.spec.minValue)/ [self.spec range];
}


@end

@implementation SCExponentialWarp

- (CGFloat)map:(CGFloat)value
{
    // minval and maxval must both be non zero and have the same sign.
    return powf([self.spec ratio], value) * self.spec.minValue;
}

- (CGFloat)unmap:(CGFloat)value
{
    return logf(value / self.spec.minValue) / logf([self.spec ratio]);
}

@end

@implementation SCFaderWarp

- (CGFloat)map:(CGFloat)value
{
    if ([self.spec range] > 0) 
    {
        return powf(value, 2) * [self.spec range] + self.spec.minValue;
    }
    return 1 - powf((1 - value), 2.0f) * [self.spec range] + self.spec.minValue;
}

- (CGFloat)unmap:(CGFloat)value
{
    if ([self.spec range] > 0) 
    {
        return sqrt((value - self.spec.minValue) / self.spec.range);
    }
    return 1 - sqrt(1 - ((value - self.spec.minValue) / [self.spec range]));
}

@end

