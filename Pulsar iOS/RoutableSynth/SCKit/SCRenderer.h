//
//  SCRenderer.h
//  Artikulator
//
//  Created by Luke Iannini on 12/8/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SCBus, SCNode, SCSynth;

typedef SCNode *(^SCRendererRenderSynthsBlock)(SCBus *renderingBus);
typedef void(^SCRendererRenderCompletionBlock)(void);
typedef void(^SCRendererRenderCompletionWithDataBlock)(NSData *soundData);

@interface SCRenderer : NSOperation

+ (NSOperationQueue *)defaultQueue;

// If passed a path, SCRenderer will look to see if a sound file exists in that path already and then return isFinished YES and be ready to call spawnPlaybackSynthWithOutputBus
- (id)initWithDuration:(NSInteger)theDurationInSamples path:(NSString *)aPath;

@property (nonatomic, readonly) BOOL renderingIsReady;

- (SCSynth *)spawnPlaybackSynthWithOutputBus:(SCBus *)outputBus;

- (void)postContents;

- (void)free;

// The RenderSynthsBlock must return the root node of the synths being recorded so the recorder can be spawned after that node
@property (nonatomic, copy) SCRendererRenderSynthsBlock renderSynthsBlock;
@property (nonatomic, copy) SCRendererRenderCompletionBlock renderSynthsCompleteBlock;
@property (nonatomic) BOOL writeData;
@property (nonatomic, copy) SCRendererRenderCompletionWithDataBlock renderSynthsDataCompleteBlock;

@end
