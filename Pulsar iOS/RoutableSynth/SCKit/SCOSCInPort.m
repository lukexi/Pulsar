//
//  SCOSCInPort.m
//  Artikulator
//
//  Created by Luke Iannini on 8/20/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "SCOSCInPort.h"

@implementation SCOSCInPort

- (id) initWithPort:(unsigned short)p labelled:(NSString *)l	{
	pthread_mutexattr_t		attr;
	
	if (self = [super init])	{
		deleted = NO;
		port = p;
		
		pthread_mutexattr_init(&attr);
		pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
		pthread_mutex_init(&lock, &attr);
		pthread_mutexattr_destroy(&attr);
		
		threadLooper = [[VVThreadLoop alloc]
                        initWithTimeInterval:0.03
                        target:self
                        selector:@selector(OSCThreadProc)];
		
		portLabel = nil;
		if (l != nil)
			portLabel = [l copy];
		
		scratchArray = [NSMutableArray arrayWithCapacity:0];
		
		delegate = nil;
		
		zeroConfDest = nil;
	}
    return self;
}

- (void)setSocket:(int)aSock
{
    sock = aSock;
    bound = [self createSocket];
}

- (BOOL) createSocket	{
    // Override to reuse the same socket as an OSCOutPort
    // so that that port always presents this in port as its return destination
    // for SCServer's /reply functionality
	// Sock should be set via setSocket already
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	memset(addr.sin_zero, '\0', sizeof(addr.sin_zero));
	//	bind the socket
	if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0)	{
		NSLog(@"\t\terr: couldn't bind socket for OSC");
		return NO;
	}
	
	return YES;
}

@end
