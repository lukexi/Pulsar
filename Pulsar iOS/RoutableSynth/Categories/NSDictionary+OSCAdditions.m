//
//  NSDictionary+OSCAdditions.m
//  RoutableSynth
//
//  Created by Luke Iannini on 12/27/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "NSDictionary+OSCAdditions.h"
#import "OSCValue+Additions.h"

@implementation NSDictionary (OSCAdditions)

- (NSArray *)sc_asOSCArgsArray
{
    __block NSMutableArray *argsArray = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
    {
        OSCValue *OSCKey = [OSCValue sc_valueWithObject:key];
        OSCValue *OSCVal = [OSCValue sc_valueWithObject:obj];
        [argsArray addObject:OSCKey];
        [argsArray addObject:OSCVal];
    }];
    return argsArray;
}

@end
