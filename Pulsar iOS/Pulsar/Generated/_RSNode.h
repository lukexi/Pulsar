// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSNode.h instead.

#import <CoreData/CoreData.h>


@class RSInput;
@class RSWire;
@class RSSynthDef;
@class RSGraph;
@class RSGraph;





@interface RSNodeID : NSManagedObjectID {}
@end

@interface _RSNode : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RSNodeID*)objectID;



@property (nonatomic, retain) NSNumber *x;

@property float xValue;
- (float)xValue;
- (void)setXValue:(float)value_;

//- (BOOL)validateX:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *y;

@property float yValue;
- (float)yValue;
- (void)setYValue:(float)value_;

//- (BOOL)validateY:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *nodeID;

//- (BOOL)validateNodeID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* inputs;
- (NSMutableSet*)inputsSet;



@property (nonatomic, retain) NSSet* outWires;
- (NSMutableSet*)outWiresSet;



@property (nonatomic, retain) RSSynthDef* synthDef;
//- (BOOL)validateSynthDef:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) RSGraph* graphAsCompletion;
//- (BOOL)validateGraphAsCompletion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) RSGraph* graph;
//- (BOOL)validateGraph:(id*)value_ error:(NSError**)error_;




@end

@interface _RSNode (CoreDataGeneratedAccessors)

- (void)addInputs:(NSSet*)value_;
- (void)removeInputs:(NSSet*)value_;
- (void)addInputsObject:(RSInput*)value_;
- (void)removeInputsObject:(RSInput*)value_;

- (void)addOutWires:(NSSet*)value_;
- (void)removeOutWires:(NSSet*)value_;
- (void)addOutWiresObject:(RSWire*)value_;
- (void)removeOutWiresObject:(RSWire*)value_;

@end

@interface _RSNode (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveX;
- (void)setPrimitiveX:(NSNumber*)value;

- (float)primitiveXValue;
- (void)setPrimitiveXValue:(float)value_;




- (NSNumber*)primitiveY;
- (void)setPrimitiveY:(NSNumber*)value;

- (float)primitiveYValue;
- (void)setPrimitiveYValue:(float)value_;




- (NSString*)primitiveNodeID;
- (void)setPrimitiveNodeID:(NSString*)value;





- (NSMutableSet*)primitiveInputs;
- (void)setPrimitiveInputs:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOutWires;
- (void)setPrimitiveOutWires:(NSMutableSet*)value;



- (RSSynthDef*)primitiveSynthDef;
- (void)setPrimitiveSynthDef:(RSSynthDef*)value;



- (RSGraph*)primitiveGraphAsCompletion;
- (void)setPrimitiveGraphAsCompletion:(RSGraph*)value;



- (RSGraph*)primitiveGraph;
- (void)setPrimitiveGraph:(RSGraph*)value;


@end
