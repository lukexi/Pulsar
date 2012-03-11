//
//  RSMetro.m
//  Pulsar
//
//  Created by Luke Iannini on 3/11/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "RSMetro.h"

@implementation RSMetro
{
    NSTimer *timer;
}

+ (RSMetro *)sharedMetro
{
    static RSMetro *sharedMetro = nil;
    if (!sharedMetro) 
    {
        sharedMetro = [[self alloc] init];
    }
    return sharedMetro;
}



@end
