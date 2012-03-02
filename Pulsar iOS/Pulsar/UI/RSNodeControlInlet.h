//
//  RSNodeControlInlet.h
//  NodeCanvasKit
//
//  Created by Luke Iannini on 11/26/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "NKNodeInlet.h"

@class RSNodeControlInlet;

@protocol RSNodeControlInletDelegate <NSObject>

- (void)nodeControlInlet:(RSNodeControlInlet *)nodeControlInlet didChangeMod:(CGFloat)modValue;
- (void)nodeControlInlet:(RSNodeControlInlet *)nodeControlInlet didChangeCenter:(CGFloat)centerValue;

@end

@interface RSNodeControlInlet : NKNodeInlet

+ (RSNodeControlInlet *)nodeControlInletWithName:(NSString *)name 
                                        modValue:(CGFloat)modValue 
                                     centerValue:(CGFloat)centerValue 
                                        delegate:(id <RSNodeControlInletDelegate>)delegate
                                      inNodeView:(NKNodeView *)nodeView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) CGFloat modValue;
@property (nonatomic) CGFloat centerValue;
@property (nonatomic) NSRange range;
@property (nonatomic, strong) NSString *units;

@property (weak, nonatomic) id <RSNodeControlInletDelegate> delegate;

@end

