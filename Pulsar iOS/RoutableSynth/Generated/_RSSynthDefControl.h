// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSSynthDefControl.h instead.

#import <CoreData/CoreData.h>


@class RSInput;
@class RSSynthDef;









@interface RSSynthDefControlID : NSManagedObjectID {}
@end

@interface _RSSynthDefControl : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RSSynthDefControlID*)objectID;



@property (nonatomic, retain) NSNumber *rateInteger;

@property int rateIntegerValue;
- (int)rateIntegerValue;
- (void)setRateIntegerValue:(int)value_;

//- (BOOL)validateRateInteger:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *warpSpecifier;

//- (BOOL)validateWarpSpecifier:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *defaultValue;

@property float defaultValueValue;
- (float)defaultValueValue;
- (void)setDefaultValueValue:(float)value_;

//- (BOOL)validateDefaultValue:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *units;

//- (BOOL)validateUnits:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *rangeLow;

@property float rangeLowValue;
- (float)rangeLowValue;
- (void)setRangeLowValue:(float)value_;

//- (BOOL)validateRangeLow:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *rangeHigh;

@property float rangeHighValue;
- (float)rangeHighValue;
- (void)setRangeHighValue:(float)value_;

//- (BOOL)validateRangeHigh:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* nodeInputs;
- (NSMutableSet*)nodeInputsSet;



@property (nonatomic, retain) RSSynthDef* synthDef;
//- (BOOL)validateSynthDef:(id*)value_ error:(NSError**)error_;




@end

@interface _RSSynthDefControl (CoreDataGeneratedAccessors)

- (void)addNodeInputs:(NSSet*)value_;
- (void)removeNodeInputs:(NSSet*)value_;
- (void)addNodeInputsObject:(RSInput*)value_;
- (void)removeNodeInputsObject:(RSInput*)value_;

@end

@interface _RSSynthDefControl (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveRateInteger;
- (void)setPrimitiveRateInteger:(NSNumber*)value;

- (int)primitiveRateIntegerValue;
- (void)setPrimitiveRateIntegerValue:(int)value_;




- (NSString*)primitiveWarpSpecifier;
- (void)setPrimitiveWarpSpecifier:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveDefaultValue;
- (void)setPrimitiveDefaultValue:(NSNumber*)value;

- (float)primitiveDefaultValueValue;
- (void)setPrimitiveDefaultValueValue:(float)value_;




- (NSString*)primitiveUnits;
- (void)setPrimitiveUnits:(NSString*)value;




- (NSNumber*)primitiveRangeLow;
- (void)setPrimitiveRangeLow:(NSNumber*)value;

- (float)primitiveRangeLowValue;
- (void)setPrimitiveRangeLowValue:(float)value_;




- (NSNumber*)primitiveRangeHigh;
- (void)setPrimitiveRangeHigh:(NSNumber*)value;

- (float)primitiveRangeHighValue;
- (void)setPrimitiveRangeHighValue:(float)value_;





- (NSMutableSet*)primitiveNodeInputs;
- (void)setPrimitiveNodeInputs:(NSMutableSet*)value;



- (RSSynthDef*)primitiveSynthDef;
- (void)setPrimitiveSynthDef:(RSSynthDef*)value;


@end
