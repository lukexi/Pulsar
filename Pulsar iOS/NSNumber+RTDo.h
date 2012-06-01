//
//  NSNumber+RTDo.h
//  Routine
//
//  Created by Luke Iannini on 5/31/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RTDoFunction)(NSNumber *index);
typedef id(^RTCollectFunction)(NSNumber *index);

@protocol RTDo <NSObject>

- (void)rt_do:(RTDoFunction)function;

@end

@interface NSNumber (RTDo) <RTDo>

- (NSArray *)rt_collect:(RTCollectFunction)function;

@end

@interface NSValue (TypeAdditions)

- (BOOL)rt_isIntegerType;
- (BOOL)rt_isFloatType;
- (BOOL)rt_isBOOLType;

@end

@interface NSNumber (RTAdditions)

- (BOOL)rt_isFloat;
- (BOOL)rt_isInt;
- (NSNumber *)rt_rand;
- (NSNumber *)rt_exprand:(NSNumber *)value2;
- (NSNumber *)rt_xrand2Excluding:(NSNumber *)exclude;
- (NSNumber *)rt_foldLow:(NSNumber *)low high:(NSNumber *)high;
- (NSNumber *)rt_rangedRandAsLowWithHigh:(NSNumber *)high;
- (NSNumber *)rt_abs;
@end

NSInteger xrand2Int(NSInteger intValue, NSInteger excludingValue);
CGFloat xrand2Float(CGFloat floatValue, CGFloat excludingValue);

CGFloat foldFloat(CGFloat value, CGFloat low, CGFloat high);
NSInteger foldInt(NSInteger value, NSInteger low, NSInteger high);

double exprandrng(double lo, double hi);