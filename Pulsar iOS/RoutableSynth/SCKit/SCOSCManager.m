//
//  SCOSCManager.m
//  Artikulator
//
//  Created by Luke Iannini on 8/20/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCOSCManager.h"
#import "SCOSCOutPort.h"
#import "SCOSCInPort.h"

@implementation SCOSCManager

- (OSCInPort *) createNewInputForPort:(int)p withLabel:(NSString *)l	{
	//NSLog(@"%s ... %ld, %@",__func__,p,l);
	SCOSCInPort			*returnMe = nil;
	NSEnumerator		*it;
	OSCInPort			*portPtr;
	BOOL				foundPortConflict = NO;
	BOOL				foundNameConflict = NO;
	
	[inPortArray wrlock];
    //	check for port or name conflicts
    it = [inPortArray objectEnumerator];
    while ((portPtr = [it nextObject]) && (!foundPortConflict) && (!foundNameConflict))	{
        if ([portPtr port] == p)
            foundPortConflict = YES;
        if (([portPtr portLabel]!=nil) && ([[portPtr portLabel] isEqualToString:l]))
            foundNameConflict = YES;
    }
    //	if there weren't any conflicts, make an instance set it up and add it to the array
    if ((!foundPortConflict) && (!foundNameConflict))	{
        Class			inPortClass = [self inPortClass];
        
        returnMe = [[inPortClass alloc] initWithPort:p labelled:l];
        
        if (returnMe != nil)	{
            
            SCOSCOutPort *sharedOutPort = (SCOSCOutPort *)[self findOutputWithLabel:l];
            NSAssert1(sharedOutPort, @"Must create an SCOSCOutPort with the same label (%@) before creating a shared input port", l);
            [returnMe setSocket:sharedOutPort.sock];
            
            [returnMe setDelegate:self];
            [returnMe start];
            [inPortArray addObject:returnMe];
        }
    }
	[inPortArray unlock];
	//	if i made an in port, i should let the delegate know that stuff changed
	if (returnMe != nil)	{
		//	if there's a delegate and it responds to the setupChanged method, let it know that stuff changed
		if ((delegate!=nil)&&([delegate respondsToSelector:@selector(setupChanged)]))
			[delegate setupChanged];
	}
	return returnMe;
}

- (id) inPortClass	{
	return [SCOSCInPort class];
}

- (id) outPortClass	{
	return [SCOSCOutPort class];
}

@end
