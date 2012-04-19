//
//  PSPlayer.h
//  PSPattern
//
//  Created by Luke Iannini on 3/25/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 E.g.
 player = [PSPlayer playerWithPatterns:
              @[
                  @"note", [PSEvery every:3 apply:[PSRotate rotate:-3] to:[PSListPattern listPatternWithValues:self.notes]],
                  @"dur", @[@0.25, @0.5, @0.125]
              ]
                                    block:^(NSDictionary *event)
              {
                  graph[@"sin"][@"freq"].center = event[@"note"];
                  
                  CGFloat value = [event[@"note"] floatValue] / 1100.0;
                  
                  [UIView animateWithDuration:interpolationTime animations:^{
                      self.center = CGPointMake(self.center.x, self.superview.bounds.size.height * value);
                      self.backgroundColor = [UIColor colorWithHue:value saturation:0.9 brightness:0.9 alpha:1];
                  }];
              }];
    [player play];
 */

static NSString *PSDurationKey = @"dur";

typedef void(^PSEventBlock)(NSDictionary *event);

@interface PSPlayer : NSObject

// Pattern descriptions must be arrays so later keys can depend on earlier ones.
+ (PSPlayer *)playerWithPatterns:(NSArray *)patternsByKey
                          blocks:(NSArray *)blocks;

+ (PSPlayer *)playerWithPatterns:(NSArray *)patternsByKey
                           block:(PSEventBlock)block;

- (void)play;
- (void)stop;

@end
