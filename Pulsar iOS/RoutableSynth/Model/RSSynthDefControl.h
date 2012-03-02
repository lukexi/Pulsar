#import "_RSSynthDefControl.h"
#import "SCServer.h"
#import "SCControlSpec.h"

@interface RSSynthDefControl : _RSSynthDefControl {}

@property (nonatomic, readonly) SCSynthRate rate;

@property (weak, nonatomic, readonly) SCControlSpec *spec;

@end
