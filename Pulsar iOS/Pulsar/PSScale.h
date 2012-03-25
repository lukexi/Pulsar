//
//  PSScale.h
//  Pulsar
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSScale : NSObject

+ (PSScale *)scaleWithDegrees:(NSArray *)degrees;

+ (PSScale *)majorScale;

@property (nonatomic, strong, readonly) NSArray *degrees;

- (NSUInteger)degreeAtIndex:(NSUInteger)index;

@end
