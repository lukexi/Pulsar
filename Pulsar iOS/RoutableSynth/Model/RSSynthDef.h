#import "_RSSynthDef.h"
#import "SCServer.h"

@interface RSSynthDef : _RSSynthDef {}

+ (RSSynthDef *)synthDefNamed:(NSString *)name inContext:(NSManagedObjectContext *)context;

- (SCSynthRate)outputRate;

@end

@interface RSSynthDef (LibraryUpdating)

+ (void)updateDefsInContext:(NSManagedObjectContext *)context;

+ (NSDictionary *)synthDefsByNameInContext:(NSManagedObjectContext *)context;
- (NSDictionary *)controlsByName;

@end