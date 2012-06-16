//
//  SCServer.m
//  Artikulator
//
//  Created by Luke Iannini on 6/28/10.
//  Copyright 2010 P.W. Worm & Co & Sons All rights reserved.
//

#import "SCServer.h"
#import <AudioToolbox/AudioToolbox.h>
#include "SC_World.h"
#include "SC_CoreAudio.h"
#include "SC_WorldOptions.h"
#include "SC_Graph.h"
#include "SC_GraphDef.h"
#include "SC_Prototypes.h"
#include "SC_Node.h"
#include "SC_DirUtils.h"
#import "NSArray+SCSynthAdditions.h"
#import "OSCMessage+AddArguments.h"
#import "SCSynth.h"
#import "SCGroup.h"
#import "SCBuffer.h"
#import "OSCValue+Additions.h"
#import "SCIDAllocator.h"
#import "SCOSCManager.h"
#import "SCOSCInPort.h"
#import "SCOSCOutPort.h"

NSString *SCServerSyncIDKey = @"SCServerSyncIDKey";
NSString *SCServerDidSyncNotification = @"SCServerDidSyncNotification";
NSString *SCServerNodeDidEndNotification = @"SCServerNodeDidEndNotification";
NSString *SCServerNodeIDKey = @"SCServerNodeIDKey";
/*
 // Can be used to intercept server log messages if we want to pipe them into the app itself
int vpost(const char *fmt, va_list ap);
int vpost(const char *fmt, va_list ap)
{
	char buf[512];
	vsnprintf(buf, sizeof(buf), fmt, ap);

    NSString *logString = [[NSString alloc] initWithCString:buf encoding:NSASCIIStringEncoding];
    //PLog(kSC_DEBUG, @"SCServer: %@", logString);
    [logString release];

	return 0;
}
 */

@interface SCServer ()

@property (nonatomic) WorldOptions options;
@property (nonatomic) struct World *world;

@property (nonatomic, strong) SCOSCManager *manager;
@property (nonatomic, strong) SCOSCOutPort *outPort;
@property (nonatomic, strong) SCOSCInPort *inPort;

@property (nonatomic, strong) SCIDAllocator *nodeIDAllocator;
@property (nonatomic, strong) SCIDAllocator *busIDAllocator;
@property (nonatomic, strong) SCIDAllocator *bufferNumberAllocator;

@property (nonatomic, strong) NSMutableDictionary *nodesToFreeByEndingNodeID;

- (void)enableNotification;
- (void)copySynthDefs;
- (void)start;
- (void)stop;

@end


@implementation SCServer
{
    NSUInteger synthServerPort;
}
@synthesize outPort, manager, inPort;
@synthesize options, world;
@synthesize nodeIDAllocator, busIDAllocator, bufferNumberAllocator;
@synthesize nodesToFreeByEndingNodeID;


+ (id)sharedServer
{
    static SCServer *sharedInstance = nil;
    if (!sharedInstance) 
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

#define kSharedSCOSCPortLabel @"SharedSCOSCPortLabel"

- (id)init
{
    self = [super init];
    if (self)
    {
        // Choose random port between 50000 & 60000 in case a crashed app holds on to our port
        synthServerPort = arc4random() % 10000 + 50000;
        
        // Or you can use this if you want to connect to a local supercollider.app for debugging
        //synthServerPort = 57110;
        
        NSUInteger numInputBusChannels = 8; // defaults
        NSUInteger numOutputBusChannels = 8;
        
        options = kDefaultWorldOptions;
        options.mBufLength = 256;
        // It's critical to increase these for Pulsar's operation,
        // since it uses many audio & control buses for interconnection.
        options.mNumAudioBusChannels = 4096;
        options.mNumControlBusChannels = 4096;
        options.mMaxNodes = 16384;
        world = nil;
        numInputBusChannels = options.mNumInputBusChannels;
        numOutputBusChannels = options.mNumOutputBusChannels;
        
        self.nodeIDAllocator = [SCIDAllocator IDAllocatorStartingAt:1000];
        self.nodeIDAllocator.name = @"Node";
        self.busIDAllocator = [SCIDAllocator IDAllocatorStartingAt:
                               numInputBusChannels + numOutputBusChannels];
        self.busIDAllocator.name = @"Bus";
        self.bufferNumberAllocator = [SCIDAllocator IDAllocatorStartingAt:0];
        self.bufferNumberAllocator.name = @"Buffer";
        
        self.nodesToFreeByEndingNodeID = [NSMutableDictionary dictionary];
        
        //SetPrintFunc(vpost);
        
        [self copySynthDefs];
        
        // Boot up SCSynth! It doesn't work /quite/ right on the sim yet but it makes sound : )
        [self start];
        
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        // Make sure we're outputting to the speaker on the iPhone rather than the receiver
        unsigned long route = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
#endif
        
        self.manager = [[SCOSCManager alloc] init];
        self.manager.delegate = self;
        
        NSString *serverAddress = @"127.0.0.1";
        //NSString *serverAddress = @"10.0.1.180"; // to send to a remote computer running SC instead...
        self.outPort = (SCOSCOutPort *)[self.manager createNewOutputToAddress:serverAddress 
                                                                       atPort:synthServerPort 
                                                                    withLabel:kSharedSCOSCPortLabel];
        self.inPort = (SCOSCInPort *)[self.manager createNewInputForPort:synthServerPort + 1 
                                                               withLabel:kSharedSCOSCPortLabel];
        
        [self enableNotification];
        
        // WARNING this can break processing of osc messages
        // (e.g., the "amp" of RSAudioConnector wasn't being set correctly)
        // so use SCBundle debugging first, and this only as a last resort.
        //[self dumpOSC:YES];
    }
    return self;
}

- (void)enableNotification
{
    // Register for notification messages from the server, 
    // such as /done and those sent by SendTrig/SendReply
    OSCMessage *notifyMessage = [OSCMessage createWithAddress:@"/notify"];
    [notifyMessage addInt:1];
    [self.outPort sendThisMessage:notifyMessage];
}

- (void)copySynthDefs
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];

	NSError *error = nil;
	NSString *support = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dir = [support stringByAppendingPathComponent:@"/synthdefs"];
    // Always replace synthdefs in case they change. 
    // TODO can command server to just load them from the bundle — then we don't need to copy them anywhere.
    if ([fileManager fileExistsAtPath:dir])
    {
        [fileManager removeItemAtPath:dir error:&error];
    }
    
    NSString *from = [bundlePath stringByAppendingPathComponent:@"/synthdefs"];
    if ([fileManager fileExistsAtPath:from])
    {
        [fileManager copyItemAtPath:from toPath:dir error:&error];
    }
}

- (void)start
{
    NSAssert(synthServerPort, @"Must set synth server port!");
	if (world) World_Cleanup(world);
	world = World_New(&options);
	if (!world || !World_OpenUDP(world, synthServerPort)) return;
}

- (void)stop
{
	if (world) World_Cleanup(world);
	world = nil;
}
//
//- (double)averageCPU
//{
//    return world ? world->hw->mAudioDriver->GetAvgCPU() : nil;
//}
//
//- (double)peakCPU
//{
//    return world ? world->hw->mAudioDriver->GetPeakCPU() : nil;
//}

- (void)sendMessageInBundle:(OSCMessage *)message
{
    OSCBundle *bundle = [OSCBundle createWithElement:message];
    bundle.timeStamp = [NSDate dateWithTimeIntervalSinceNow:SCServerSyncDelay];
    [self sendBundle:bundle];
}

- (void)sendBundle:(OSCBundle *)bundle
{
    [self.outPort sendThisBundle:bundle];
}

- (void)sendMessage:(OSCMessage *)message
{
    [self.outPort sendThisMessage:message];
}

// Begin ObjC>SCServer interface

- (void)dumpTree
{
    [[SCGroup defaultGroup] dumpTree];
    //DLog(@"Peak %f, Average %f", [self peakCPU], [self averageCPU]);
}

- (void)clearScheduler
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/clearSched"];
    [self.outPort sendThisMessage:message];
}

- (void)freeAll
{
    [[SCGroup defaultGroup] freeAll];
    [self clearScheduler];
    
    // Limiter will get freed, add it again...
    //[self addLimiter];
}

- (void)dumpOSC:(BOOL)flag
{
    OSCMessage *message = [OSCMessage createWithAddress:@"/dumpOSC"];
    [message addInt:flag];
    [self.outPort sendThisMessage:message];
}

#pragma mark - Busses
- (SCBusID)requestBusID
{
    return [self.busIDAllocator allocateID];
}

- (void)freeBusID:(SCBusID)busID
{
    [self.busIDAllocator freeID:busID];
}

#pragma mark - Synths
- (SCNodeID)requestNodeID
{
    return [self.nodeIDAllocator allocateID];
}

- (void)freeNodeID:(SCNodeID)nodeID
{
    [self.nodeIDAllocator freeID:nodeID];
}

#pragma mark - Groups

- (void)freeAllInGroup:(SCNodeID)groupNodeID
{
    OSCMessage *allMessage = [OSCMessage createWithAddress:@"/g_freeAll"];
    [allMessage addInt:groupNodeID];
    [self sendMessageInBundle:allMessage];
    OSCMessage *freeMessage = [OSCMessage createWithAddress:@"/n_free"];
    [freeMessage addInt:groupNodeID];
    [self sendMessageInBundle:freeMessage];
}

- (void)freeNode:(SCNode *)aNode uponCompletionOfNode:(SCNode *)endingNode
{
    [self.nodesToFreeByEndingNodeID setObject:aNode 
                                       forKey:[NSNumber numberWithInteger:endingNode.nodeID]];
}

#pragma mark - Buffers
- (SCBufferNumber)requestBufferNumber
{
    return [self.bufferNumberAllocator allocateID];
}

- (void)freeBufferNumber:(SCBufferNumber)bufferNumber
{
    [self.bufferNumberAllocator freeID:bufferNumber];
}

- (void)receivedOSCMessage:(OSCMessage *)message
{
    if (![NSThread isMainThread]) 
    {
        [self performSelectorOnMainThread:@selector(receivedOSCMessage:) withObject:message waitUntilDone:NO];
        return;
    }
    //PLog(kSC_DEBUG, @"Received message: %@", [message sc_simpleDescription]);
    //NSLog(@"Received message! %@", [message sc_simpleDescription]);
    NSString *address = [message address];
    id syncID = nil;
    if ([address isEqualToString:@"/synced"]) 
    {
        syncID = [NSNumber numberWithInt:[[message value] intValue]];
    }
    else if ([address isEqualToString:@"/done"]) 
    {
        syncID = [[[message valueArray] valueForKey:@"sc_objectValue"] componentsJoinedByString:@""];
    }
    else if ([address isEqualToString:@"/tr"])
    {
        syncID = [NSNumber numberWithInt:[[message value] intValue]];
        //PLog(kSC_DEBUG, @"Got trigger: %@", syncID);
    }
    else if ([address isEqualToString:@"/n_end"])
    {
        NSNumber *nodeID = [NSNumber numberWithInteger:[[message valueAtIndex:0] intValue]];
        //NSLog(@"Node ended: %@", nodeID);
        [self freeNodeID:[nodeID integerValue]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCServerNodeDidEndNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:nodeID 
                                                                                               forKey:SCServerNodeIDKey]];
        
        SCNode *nodeToFree = [self.nodesToFreeByEndingNodeID objectForKey:nodeID];
        if (nodeToFree) 
        {
            //PLog(kSC_DEBUG, @"Node ended: %@ so freeing node: %@", nodeID, nodeToFree);
            [nodeToFree free];
            [self.nodesToFreeByEndingNodeID removeObjectForKey:nodeID];
        }
    }
    else if ([address isEqualToString:@"/b_setn"])
    {
        NSMutableArray *values = [message valueArray];
        NSLog(@"Values: %@", values);
    }
    
    if (syncID) 
    {
        //PLog(kSC_DEBUG, @"synced ID: %@", syncID);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:syncID 
                                                             forKey:SCServerSyncIDKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:SCServerDidSyncNotification 
                                                            object:self 
                                                          userInfo:userInfo];
    }
}

- (void)postAllocatedNodeIDs
{
#if SCTestAllocatedNodeIDs
    NSLog(@"Allocated Node IDs: %@", self.nodeIDAllocator.allocatedIDs);
    NSLog(@"Allocated Bus IDs: %@", self.busIDAllocator.allocatedIDs);
    NSLog(@"Allocated Buffer Numberss: %@", self.bufferNumberAllocator.allocatedIDs);
#endif
}

- (void)addLimiter
{
    SCSynth *synth = [SCSynth synthWithName:@"limiter" arguments:nil];
    synth.nodeID = SCTransientNodeID;
    [synth send];
}

- (void)testTone
{
    [SCSynth synthWithName:@"SinesthesiaTouch" 
                 arguments:[NSArray arrayWithObjects:
                            [OSCValue createWithString:@"pitch"], 
                            [OSCValue createWithInt:440], nil] 
                   sentNow:YES];
}

- (void)stressTest
{
    // Stress Test with 400 sines
    [SCSynth synthWithName:@"StressTest" arguments:nil sentNow:YES];
}

- (void)synthTest
{
    [SCSynth synthWithName:@"TestSynth" arguments:nil sentNow:YES];
}

@end

