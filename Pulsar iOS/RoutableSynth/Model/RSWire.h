#import "_RSWire.h"
#import "RSServerObject.h"

@interface RSWire : _RSWire <RSServerObject> {}
// Custom logic goes here.

+ (RSWire *)existingWireFrom:(RSNode *)sourceNode to:(RSInput *)destinationInput;
+ (RSWire *)wireFrom:(RSNode *)sourceNode to:(RSInput *)destinationInput atAmp:(CGFloat)amp;

@end
