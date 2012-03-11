//
//  RSMetro.h
//  Pulsar
//
//  Created by Luke Iannini on 3/11/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSMetro : NSObject

+ (RSMetro *)sharedMetro;

@property (nonatomic) CGFloat tempo;

@end
