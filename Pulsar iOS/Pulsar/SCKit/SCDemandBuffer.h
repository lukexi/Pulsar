//
//  SDDemandBuffer.h
//  SpringDudes
//
//  Created by Luke Iannini on 3/4/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCDemandBuffer : NSObject

@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSArray *waits;

// Call inside of SCBundle before setting up things that need to use our buffers
- (void)sendSamples;

- (NSDictionary *)demandEnvGenInitialArguments;
- (NSDictionary *)timedEnvelopeInitialArguments;

@end
