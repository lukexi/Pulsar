#import "_RSInput.h"
#import "RSServerObject.h"
#import "RSSynthDefControl.h"

@class SCBus;
@class SCSynth;
@interface RSInput : _RSInput <RSServerObject> {}

@property (nonatomic, strong, readonly) SCBus *inputSummingBus;
@property (nonatomic, strong, readonly) SCSynth *scalerNode;

@end
