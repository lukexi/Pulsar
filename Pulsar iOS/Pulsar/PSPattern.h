//
//  PSPattern.h
//  PSPattern
//
//  Created by Luke Iannini on 3/24/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSStream, PSPattern;
@protocol PSPatternable <NSObject>

- (PSPattern *)asPattern;

@end

@interface PSPattern : NSObject <PSPatternable>

+ (id)patternWithValues:(NSArray *)values;

@property (nonatomic, readonly) NSArray *values;

- (PSStream *)asStream;

@end

@interface PSEvery : PSPattern



@end