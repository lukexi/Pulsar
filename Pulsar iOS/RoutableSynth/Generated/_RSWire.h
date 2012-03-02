// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSWire.h instead.

#import <CoreData/CoreData.h>


@class RSInput;
@class RSNode;



@interface RSWireID : NSManagedObjectID {}
@end

@interface _RSWire : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RSWireID*)objectID;



@property (nonatomic, retain) NSNumber *amp;

@property float ampValue;
- (float)ampValue;
- (void)setAmpValue:(float)value_;

//- (BOOL)validateAmp:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RSInput* destinationInput;
//- (BOOL)validateDestinationInput:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) RSNode* sourceNode;
//- (BOOL)validateSourceNode:(id*)value_ error:(NSError**)error_;




@end

@interface _RSWire (CoreDataGeneratedAccessors)

@end

@interface _RSWire (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAmp;
- (void)setPrimitiveAmp:(NSNumber*)value;

- (float)primitiveAmpValue;
- (void)setPrimitiveAmpValue:(float)value_;





- (RSInput*)primitiveDestinationInput;
- (void)setPrimitiveDestinationInput:(RSInput*)value;



- (RSNode*)primitiveSourceNode;
- (void)setPrimitiveSourceNode:(RSNode*)value;


@end
