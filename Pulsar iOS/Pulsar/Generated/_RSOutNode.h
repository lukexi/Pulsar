// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSOutNode.h instead.

#import <CoreData/CoreData.h>
#import "RSNode.h"

@class RSGraph;


@interface RSOutNodeID : NSManagedObjectID {}
@end

@interface _RSOutNode : RSNode {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RSOutNodeID*)objectID;




@property (nonatomic, retain) RSGraph* graphAsOut;
//- (BOOL)validateGraphAsOut:(id*)value_ error:(NSError**)error_;




@end

@interface _RSOutNode (CoreDataGeneratedAccessors)

@end

@interface _RSOutNode (CoreDataGeneratedPrimitiveAccessors)



- (RSGraph*)primitiveGraphAsOut;
- (void)setPrimitiveGraphAsOut:(RSGraph*)value;


@end
