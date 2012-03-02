//
//  SCSoundFileLibrary.m
//  Artikulator
//
//  Created by Luke Iannini on 9/26/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "SCSoundFileLibrary.h"
#import "SCServer.h"
#import "SCBuffer.h"

@interface SCSoundFileLibrary ()

- (void)loadSounds;

@property (nonatomic, strong) NSMutableDictionary *soundFilesByBufferNumber;

@end

@implementation SCSoundFileLibrary
@synthesize soundFilesByBufferNumber;


- (id)init 
{
    self = [super init];
    if (self) 
    {
        self.soundFilesByBufferNumber = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)loadSounds
{
    //NSArray *sounds = [NSArray arrayWithObjects:@"a11wlk01.wav", nil];
    NSArray *sounds = [NSArray arrayWithObjects:@"bamanpiderman.wav", nil];
    for (NSString *soundName in sounds)
    {
#if !TARGET_IPHONE_SIMULATOR
        NSString *soundPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:soundName];
        // crashes the simulator, maybe something with libsndfile not being loaded correctly??
        SCBuffer *buffer = [SCBuffer bufferWithPath:soundPath];
        [self.soundFilesByBufferNumber setObject:buffer forKey:soundName];
#endif
    }
}

@end
