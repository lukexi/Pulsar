//
//  SCControlSpec.h
//  Artikulator
//
//  Created by Luke Iannini on 9/10/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCWarp;
@interface SCControlSpec : NSObject

+ (id)controlSpecWithMin:(CGFloat)min
                     max:(CGFloat)max
           warpSpecifier:(NSString *)specifier
                   units:(NSString *)units;

@property (nonatomic) CGFloat minValue;
@property (nonatomic) CGFloat maxValue;

@property (nonatomic, strong) SCWarp *warp;
@property (nonatomic, strong) NSString *units;

- (CGFloat)map:(CGFloat)value;
- (CGFloat)unmap:(CGFloat)value;

- (CGFloat)range;
- (CGFloat)ratio;

@end

@interface SCWarp : NSObject

+ (Class)warpClassForSpecifier:(NSString *)specifier;

+ (id)warpForSpec:(SCControlSpec *)spec;

@property (nonatomic, weak) SCControlSpec *spec;

- (CGFloat)map:(CGFloat)value;
- (CGFloat)unmap:(CGFloat)value;

@end

@interface SCLinearWarp : SCWarp 

@end

@interface SCExponentialWarp : SCWarp 

@end

@interface SCFaderWarp : SCWarp 

@end