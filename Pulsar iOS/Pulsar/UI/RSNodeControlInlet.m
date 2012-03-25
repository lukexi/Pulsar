//
//  RSNodeControlInlet.m
//  NodeCanvasKit
//
//  Created by Luke Iannini on 11/26/11.
//  Copyright (c) 2011 Eeoo. All rights reserved.
//

#import "RSNodeControlInlet.h"
#import "NKCircleView.h"
#import "NKDragButton.h"

@interface RSNodeControlInlet ()
{
    IBOutlet NKCircleView *circleView;
    IBOutlet NKDragButton *modButton;
    IBOutlet NKDragButton *centerButton;
    IBOutlet UIView *containerView;
}

@end

@implementation RSNodeControlInlet
@synthesize titleLabel;
@synthesize modValue, center;
@synthesize delegate;
@synthesize units;
@synthesize range;

+ (RSNodeControlInlet *)nodeControlInletWithName:(NSString *)name 
                                        modValue:(CGFloat)modValue 
                                     center:(CGFloat)center 
                                        delegate:(id <RSNodeControlInletDelegate>)delegate
                                      inNodeView:(NKNodeView *)nodeView
{
    RSNodeControlInlet *inlet = [super XLetForNode:nodeView];
    inlet.name = name;
    inlet.modValue = modValue;
    inlet.center = center;
    inlet.delegate = delegate;
    return inlet;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) 
    {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        self.frame = containerView.frame;
        [self addSubview:containerView];
        containerView.backgroundColor = [UIColor clearColor];
        
        NKShapeView *borderView = [[NKShapeView alloc] initWithFrame:containerView.bounds];
        borderView.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        borderView.strokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        borderView.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(containerView.bounds, 2, 2) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 10)];
        [containerView insertSubview:borderView atIndex:0];
        
        modButton.formatter = ^NSString *(CGFloat value) 
        {
            return [NSString stringWithFormat:@"*%.2f", value];
        };
    }
    return self;
}

- (void)setUnits:(NSString *)theUnits
{
    units = theUnits;
    centerButton.formatter = ^NSString *(CGFloat value) 
    {
        return [NSString stringWithFormat:@"+%.2f%@", value, theUnits ?: @""];
    };
}

- (void)setName:(NSString *)name
{
    [super setName:name];
    self.titleLabel.text = name;
}

- (void)setModValue:(CGFloat)aModValue
{
    modValue = aModValue;
    modButton.value = aModValue;
}

- (void)setCenter:(CGFloat)aCenter
{
    CGFloat constrainedValue = self.range.length ? MIN(MAX(aCenter, self.range.location), NSMaxRange(self.range)) : aCenter;
    center = constrainedValue;
    centerButton.value = center;
}

- (IBAction)modValueChanged:(id)sender 
{
    NKDragButton *button = sender;
    self.modValue = button.value;
    [self.delegate nodeControlInlet:self didChangeMod:self.modValue];
}

- (IBAction)centerChanged:(id)sender 
{
    NKDragButton *button = sender;
    self.center = button.value;
    [self.delegate nodeControlInlet:self didChangeCenter:self.center];
}

// Overrides
- (CGPoint)connectionPointInView:(UIView *)aView
{
    return [aView convertPoint:circleView.center fromView:[circleView superview]];
}

+ (CGSize)XLetSize
{
    static CGSize inletSize;
    if (CGSizeEqualToSize(inletSize, CGSizeZero)) 
    {
        RSNodeControlInlet *referenceInlet = [[self alloc] initWithFrame:CGRectZero];
        inletSize = referenceInlet.frame.size;
    }
    return inletSize;
}

@end