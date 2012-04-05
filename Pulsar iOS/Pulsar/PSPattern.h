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

@interface PSEvery : PSPattern

+ (id)every:(NSUInteger)times apply:(PSFilterPattern *)filterPattern to:(PSListPattern *)listPattern;

@property (nonatomic, readonly) NSUInteger every;
@property (nonatomic, strong, readonly) PSFilterPattern *filter;
@property (nonatomic, strong, readonly) PSListPattern *listPattern;

@end

// Abstract class
@interface PSFilterPattern : PSPattern

- (NSArray *)filter:(PSListPattern *)listPattern;

@end

@interface PSRotate : PSFilterPattern

+ (PSRotate *)rotate:(NSInteger)places;

@property (nonatomic, readonly) NSInteger places;

@end