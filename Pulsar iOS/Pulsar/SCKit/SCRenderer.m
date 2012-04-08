//
//  SCRenderer.m
//  Artikulator
//
//  Created by Luke Iannini on 12/8/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "SCRenderer.h"
#import "SCBuffer.h"
#import "SCBus.h"
#import "SCSynth.h"
#import "SCBundle.h"

@interface SCRenderer ()
{
    NSInteger durationInSamples;
    SCSynth *recorderSynth;
    SCSynth *playbackSynth;
    
    BOOL isFinished;
    BOOL isExecuting;
}

@property (nonatomic, strong) SCBuffer *renderingBuffer;
@property (nonatomic, strong) SCBus *renderingBus;
@property (nonatomic, strong) NSString *path;

@property (nonatomic, readwrite) BOOL renderingIsReady;

- (void)writeToFile;

@end

@implementation SCRenderer
@synthesize renderingBuffer, renderingBus, path, renderingIsReady;
@synthesize renderSynthsBlock, renderSynthsCompleteBlock, renderSynthsDataCompleteBlock;
@synthesize writeData;

+ (NSOperationQueue *)defaultQueue
{
    static NSOperationQueue *defaultQueue;
    if (!defaultQueue) 
    {
        defaultQueue = [[NSOperationQueue alloc] init];
        defaultQueue.maxConcurrentOperationCount = 3;
    }
    return defaultQueue;
}

- (id)initWithDuration:(NSInteger)theDurationInSamples path:(NSString *)aPath
{
    self = [super init];
    if (self) 
    {
        durationInSamples = theDurationInSamples;
        path = aPath;
        
        if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]) 
        {
            renderingBuffer = [SCBuffer bufferWithPath:path];
            renderingIsReady = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    [self free];
}

- (void)free
{
    [renderingBus free];
    [renderingBuffer free];
}

- (SCBuffer *)renderingBuffer
{
    if (!renderingBuffer)
    {
        self.renderingBuffer = [SCBuffer bufferWithCapacity:durationInSamples];
    }
    return renderingBuffer;
}

- (SCBus *)renderingBus
{
    if (!renderingBus) 
    {
        self.renderingBus = [SCBus busWithChannels:1 rate:SCSynthAudioRate];
        //PLog(kSOUNDRENDERING_DEBUG, @"Created rendering bus! %@", renderingBus);
    }
    return renderingBus;
}

- (NSString *)path
{
    if (!path) 
    {
        path = [NSTemporaryDirectory() stringByAppendingPathComponent:
                [NSString stringWithFormat:@"Buffer%i-%f.aiff", 
                 renderingBuffer.bufferNumber, 
                 [[NSDate date] timeIntervalSinceReferenceDate]]];
    }
    return path;
}

- (BOOL)isFinished
{
    return isFinished;
}

- (BOOL)isExecuting
{
    return isExecuting;
}

- (void)start
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    renderingIsReady = NO;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    isExecuting = YES;
    isFinished = NO;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

    [SCBundle bundleMessages:^(void) 
     {
         [self renderingBuffer]; // Make sure rendering buffer creation message is added before recorder synth message
         [SCBundle sync];
         
         // Spawn synths requested by user
         SCNode *synthsNode = self.renderSynthsBlock(self.renderingBus);
         
         recorderSynth = [SCSynth synthWithName:@"BufferRecorder"
                                               arguments:[NSArray arrayWithObjects:
                                                          [OSCValue createWithString:@"inBus"],
                                                          [OSCValue createWithInt:self.renderingBus.busID],
                                                          [OSCValue createWithString:@"bufferNumber"],
                                                          [OSCValue createWithInt:self.renderingBuffer.bufferNumber],
                                                          nil]];
         recorderSynth.target = synthsNode;
         recorderSynth.addAction = SCAddAfterAction;
         [recorderSynth send];
         
         NSLog(@"Began recording %@", [self path]);
         
         [recorderSynth completionBlock:^{
             
             renderingIsReady = YES;
             
             [self willChangeValueForKey:@"isExecuting"];
             [self willChangeValueForKey:@"isFinished"];
             
             isExecuting = NO;
             isFinished = YES;
             
             [self didChangeValueForKey:@"isExecuting"];
             [self didChangeValueForKey:@"isFinished"];
             
             NSLog(@"Completed recording %@", [self path]);
             if (self.renderSynthsCompleteBlock) 
             {
                 self.renderSynthsCompleteBlock();
             }
             if (self.writeData)
             {
                 [self writeToFile];
             }
         }];
         
         //PLog(kSOUNDRENDERING_DEBUG, @"Sent recorder synth %@", recorderSynth);
         [SCBundle sync];
     }];
}

- (void)writeToFile
{
    //PLog(kSOUNDRENDERING_DEBUG, @"Writing sound data to path: %@", fileName);
    [self.renderingBuffer writeToPath:path completion:^{
        //PLog(kSOUNDRENDERING_DEBUG, @"Got sound data of length!: %u", [soundData length]);
        if (self.renderSynthsDataCompleteBlock) 
        {
            // TODO thread this once working
            NSData *soundData = [NSData dataWithContentsOfFile:path];
            self.renderSynthsDataCompleteBlock(soundData);
        }
    }];
}

- (SCSynth *)spawnPlaybackSynthWithOutputBus:(SCBus *)outputBus
{
    playbackSynth = [SCSynth synthWithName:@"BufferPlayer" 
                                 arguments:[NSArray arrayWithObjects:
                                            [OSCValue createWithString:@"outBus"], 
                                            [OSCValue createWithInt:outputBus.busID], 
                                            [OSCValue createWithString:@"bufferNumber"], 
                                            [OSCValue createWithInt:self.renderingBuffer.bufferNumber], 
                                            nil]];
    playbackSynth.hasGate = YES;
    [playbackSynth send];
    return playbackSynth;
}

- (void)postContents
{
    [self.renderingBuffer postContents];
}

@end
