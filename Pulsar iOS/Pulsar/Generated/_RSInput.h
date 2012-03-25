// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSInput.h instead.

#import <CoreData/CoreData.h>


@class RSSynthDefControl;
@class RSWire;
@class RSNode;




@interface RSInputID : NSManagedObjectID {}
@end

@interface _RSInput : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RSInputID*)objectID;



@property (nonatomic, retain) NSNumber *center;

@property float centerValue;
- (float)centerValue;
- (void)setCenterValue:(float)value_;

//- (BOOL)validateCenter:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *modDepth;

@property float modDepthValue;
- (float)modDepthValue;
- (void)setModDepthValue:(float)value_;

//- (BOOL)validateModDepth:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RSSynthDefControl* synthDefControl;
//- (BOOL)validateSynthDefControl:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* wires;
- (NSMutableSet*)wiresSet;



@property (nonatomic, retain) RSNode* node;
//- (BOOL)validateNode:(id*)value_ error:(NSError**)error_;




@end

@interface _RSInput (CoreDataGeneratedAccessors)

- (void)addWires:(NSSet*)value_;
- (void)removeWires:(NSSet*)value_;
- (void)addWiresObject:(RSWire*)value_;
- (void)removeWiresObject:(RSWire*)value_;

@end

@interface _RSInput (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCenter;
- (void)setPrimitiveCenter:(NSNumber*)value;

- (float)primitiveCenterValue;
- (void)setPrimitiveCenterValue:(float)value_;




- (NSNumber*)primitiveModDepth;
- (void)setPrimitiveModDepth:(NSNumber*)value;

- (float)primitiveModDepthValue;
- (void)setPrimitiveModDepthValue:(float)value_;





- (RSSynthDefControl*)primitiveSynthDefControl;
- (void)setPrimitiveSynthDefControl:(RSSynthDefControl*)value;



- (NSMutableSet*)primitiveWires;
- (void)setPrimitiveWires:(NSMutableSet*)value;



- (RSNode*)primitiveNode;
- (void)setPrimitiveNode:(RSNode*)value;


@end
