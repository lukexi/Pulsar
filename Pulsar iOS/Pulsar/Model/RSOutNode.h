#import "_RSOutNode.h"

@interface RSOutNode : _RSOutNode {}

+ (id)outNodeInContext:(NSManagedObjectContext *)context;

// Will be connected to the SCBus mainOutputBus by default, but you can change it
// to route this graph into another.
@property (nonatomic, strong) SCBus *outNodeOutputBus;

@end