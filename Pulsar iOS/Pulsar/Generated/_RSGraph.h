// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RSGraph.h instead.

#import <CoreData/CoreData.h>


@class RSOutNode;
@class RSNode;
@class RSNode;




@interface RSGraphID : NSManagedObjectID {}
@end

@interface _RSGraph : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RSGraphID*)objectID;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RSOutNode* outNode;
//- (BOOL)validateOutNode:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* nodes;
- (NSMutableSet*)nodesSet;



@property (nonatomic, retain) RSNode* completionNode;
//- (BOOL)validateCompletionNode:(id*)value_ error:(NSError**)error_;




@end

@interface _RSGraph (CoreDataGeneratedAccessors)

- (void)addNodes:(NSSet*)value_;
- (void)removeNodes:(NSSet*)value_;
- (void)addNodesObject:(RSNode*)value_;
- (void)removeNodesObject:(RSNode*)value_;

@end

@interface _RSGraph (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (RSOutNode*)primitiveOutNode;
- (void)setPrimitiveOutNode:(RSOutNode*)value;



- (NSMutableSet*)primitiveNodes;
- (void)setPrimitiveNodes:(NSMutableSet*)value;



- (RSNode*)primitiveCompletionNode;
- (void)setPrimitiveCompletionNode:(RSNode*)value;


@end
