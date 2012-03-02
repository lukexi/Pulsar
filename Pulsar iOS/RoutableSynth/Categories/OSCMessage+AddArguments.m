//
//  OSCMessage+AddArguments.m
//  Artikulator
//
//  Created by Luke Iannini on 7/4/10.
//  Copyright 2010 P.W. Worm & Co & Sons All rights reserved.
//

#import "OSCMessage+AddArguments.h"
#import "OSCValue+Additions.h"

@implementation OSCMessage (AddArguments)

- (void)addArguments:(NSArray *)arguments
{
    for (id argument in arguments)
    {
        if ([argument isKindOfClass:[OSCValue class]])
        {
            [self addValue:argument];
        }
        else if ([argument isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)argument;
            
            NSAssert(([((OSCValue *)[array objectAtIndex:0]) type] == OSCValArrayOpen &&
                      [((OSCValue *)[array lastObject]) type] == OSCValArrayClose),
                     @"Must have OSCValArrayOpen and Close values at start and end of arg array");

            for (OSCValue *aValue in array)
            {
                [self addValue:aValue];
            }
        }
    }
}

- (NSString *)OSCString
{
    NSMutableArray *logArray = [NSMutableArray arrayWithCapacity:[valueArray count] + 1];
    [logArray addObject:[NSString stringWithFormat:@"\"%@\"", [self address]]];
    for (OSCValue *aValue in [self valueArray])
    {
        if ([aValue type] == OSCValArrayOpen)
        {
            [logArray addObject:@"$["];
        }
        else if ([aValue type] == OSCValArrayClose)
        {
            [logArray addObject:@"$]"];
        }
        else if ([aValue type] == OSCValFloat)
        {
            [logArray addObject:[NSNumber numberWithFloat:[aValue floatValue]]];
        }
        else if ([aValue type] == OSCValInt)
        {
            [logArray addObject:[NSNumber numberWithInt:[aValue intValue]]];
        }
        else if ([aValue type] == OSCValString)
        {
            [logArray addObject:[NSString stringWithFormat:@"\"%@\"", [aValue stringValue]]];
        }
    }
    return [logArray componentsJoinedByString:@", "];
}

- (NSString *)sc_simpleDescription
{
    if (![self valueArray]) 
    {
        return [NSString stringWithFormat:@"[%@, %@]", [self address], [[self value] sc_simpleDescription]];
    }
    return [NSString stringWithFormat:@"[%@, %@]", [self address], [[[self valueArray] valueForKey:@"sc_simpleDescription"] componentsJoinedByString:@", "]];
}

@end
