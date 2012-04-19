//
//  PSPattern.h
//  PSPattern
//
//  Created by Luke Iannini on 3/24/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSStream, PSPattern, PSFilterPattern;
@protocol PSPatternable <NSObject>

- (PSPattern *)asPattern;

@end

// Abstract class
@interface PSPattern : NSObject <PSPatternable>

+ (id)pattern;

- (NSArray *)embedInStream;

- (PSStream *)asStream;

@end

@interface PSListPattern : PSPattern

+ (id)listPatternWithValues:(NSArray *)values;

@property (nonatomic, strong, readonly) NSArray *values;

@end

@interface PSBlockPattern : PSPattern

+ (id)blockPatternWithBlock:(id)block;

@property (nonatomic, copy) id block;

@end

@interface PSWhite : PSPattern

+ (id)between:(CGFloat)lowValue and:(CGFloat)highValue;

@property (nonatomic, readonly) CGFloat lowValue;
@property (nonatomic, readonly) CGFloat highValue;

@end

@interface PSEvery : PSPattern

+ (id)every:(NSUInteger)times apply:(PSFilterPattern *)filterPattern;

@property (nonatomic, readonly) NSUInteger every;
@property (nonatomic, strong, readonly) PSFilterPattern *filter;

@end

// Abstract class
@interface PSFilterPattern : PSPattern

@property (nonatomic, strong, readonly) PSListPattern *listPattern;

- (NSArray *)filteredValues;

@end

@interface PSRotate : PSFilterPattern

+ (PSRotate *)rotate:(PSListPattern *)listPattern places:(NSInteger)places;

@property (nonatomic, readonly) NSInteger places;

@end

@interface PSScramble : PSFilterPattern

+ (PSScramble *)scramble:(PSListPattern *)listPattern;

@end

@interface PSReverse : PSFilterPattern

+ (PSReverse *)reverse:(PSListPattern *)listPattern;

@end