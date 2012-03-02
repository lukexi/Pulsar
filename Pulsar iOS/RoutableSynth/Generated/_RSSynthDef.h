// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSSynthDef.h instead.

#import <CoreData/CoreData.h>


@class RSNode;
@class RSSynthDefControl;




@interface RSSynthDefID : NSManagedObjectID {}
@end

@interface _RSSynthDef : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RSSynthDefID*)objectID;



@property (nonatomic, retain) NSNumber *outputRateInteger;

@property int outputRateIntegerValue;
- (int)outputRateIntegerValue;
- (void)setOutputRateIntegerValue:(int)value_;

//- (BOOL)validateOutputRateInteger:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* nodes;
- (NSMutableSet*)nodesSet;



@property (nonatomic, retain) NSSet* controls;
- (NSMutableSet*)controlsSet;




@end

@interface _RSSynthDef (CoreDataGeneratedAccessors)

- (void)addNodes:(NSSet*)value_;
- (void)removeNodes:(NSSet*)value_;
- (void)addNodesObject:(RSNode*)value_;
- (void)removeNodesObject:(RSNode*)value_;

- (void)addControls:(NSSet*)value_;
- (void)removeControls:(NSSet*)value_;
- (void)addControlsObject:(RSSynthDefControl*)value_;
- (void)removeControlsObject:(RSSynthDefControl*)value_;

@end

@interface _RSSynthDef (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveOutputRateInteger;
- (void)setPrimitiveOutputRateInteger:(NSNumber*)value;

- (int)primitiveOutputRateIntegerValue;
- (void)setPrimitiveOutputRateIntegerValue:(int)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveNodes;
- (void)setPrimitiveNodes:(NSMutableSet*)value;



- (NSMutableSet*)primitiveControls;
- (void)setPrimitiveControls:(NSMutableSet*)value;


@end
