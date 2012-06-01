//
//  NSDictionary+OSCAdditions.m
//  Pulsar
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
        if (OSCVal)
        {
            [argsArray addObject:OSCKey];
            [argsArray addObject:OSCVal];
        }
        else if ([obj isKindOfClass:[NSArray class]])
        {
            [self sc_addObjectsToArgsArray:argsArray
               asOSCArrayfromValuesInArray:obj
                                    forKey:OSCKey];
        }
    }];
    return argsArray;
}

- (void)sc_addObjectsToArgsArray:(NSMutableArray *)argsArray
     asOSCArrayfromValuesInArray:(NSArray *)originalArray
                          forKey:(OSCValue *)OSCKey
{
    BOOL allConverted = YES;
    NSMutableArray *arrayOSCValues = [NSMutableArray array];
    for (id arrayElement in originalArray)
    {
        OSCValue *value = [OSCValue sc_valueWithObject:arrayElement];
        if (value)
        {
            [arrayOSCValues addObject:value];
        }
        else
        {
            allConverted = NO;
        }
    }
    if (allConverted)
    {
        [argsArray addObject:OSCKey];
        [argsArray addObject:[OSCValue createWithArrayOpen]];
        [argsArray addObjectsFromArray:arrayOSCValues];
        [argsArray addObject:[OSCValue createWithArrayClose]];
    }
    else
    {
        NSLog(@"Couldn't convert array to OSC: %@", originalArray);
    }
}

@end
