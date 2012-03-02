//
//  SCBus.h
//  Artikulator
//
//  Created by Luke Iannini on 6/25/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCServer.h"

@interface SCBus : NSObject <NSCopying>

+ (SCBus *)mainOutputBus;
+ (SCBus *)busWithChannels:(NSUInteger)channels rate:(SCSynthRate)rate;

@property (nonatomic) SCBusID busID;
@property (nonatomic) NSUInteger numberOfChannels;
@property (nonatomic) SCSynthRate rate;

- (void)free;

@end
