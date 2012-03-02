#import "_RSOutNode.h"

@interface RSOutNode : _RSOutNode {}

+ (id)outNodeInContext:(NSManagedObjectContext *)context;

- (void)connectToMainOutput;
- (void)connectToBus:(SCBus *)externalBus;

@end