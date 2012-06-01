//
//  SCFuncStream.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTStream.h"

typedef id(^RTFuncStreamFunc)(id inValue);

@interface RTFuncStream : RTStream

+ (RTFuncStream *)funcStreamWithFunc:(RTFuncStreamFunc)func;

@end
