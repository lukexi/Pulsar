//
//  RSServerObject.h
//  Artikulator
//
//  Created by Luke Iannini on 9/6/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSServerObject <NSObject>

- (void)spawn;
- (void)free;
@property (nonatomic, readonly) BOOL isSpawned;

@end
