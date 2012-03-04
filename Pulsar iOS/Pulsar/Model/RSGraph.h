#import "_RSGraph.h"
#import "RSServerObject.h"

@class SCBus;
@class SCGroup;
@class RSOutNodeInstance;
@class RSSynthDef;

@interface RSGraph : _RSGraph <RSServerObject> {}

// Optional, to spawn the whole graph in another group.
@property (nonatomic, strong) SCGroup *superGroup;
@property (nonatomic, strong, readonly) SCGroup *graphGroup;
@property (nonatomic) NSTimeInterval lagTime;

@property (nonatomic, readonly) BOOL isSpawned;

// Creation
+ (id)graphFromDictionary:(NSDictionary *)dictionary 
                inContext:(NSManagedObjectContext *)context;
+ (id)graphFromGraph:(RSGraph *)graphToCopy
           inContext:(NSManagedObjectContext *)context;
// For polyphony
- (RSGraph *)graphCopy;

// Querying
- (NSString *)nodeIDForNewNodeWithSynthDef:(RSSynthDef *)synthDef;
- (RSNode *)nodeWithID:(NSString *)nodeID;

// Manipulation
- (RSNode *)addNodeWithID:(NSString *)nodeID fromSynthDefNamed:(NSString *)synthDefName;
- (RSNode *)addNodeFromSynthDef:(RSSynthDef *)synthDef; // Automatic node ID (synth def name + number of nodes in the graph using that synthdef — e.g. "SinOsc-KR0")
- (void)addNode:(RSNode *)synth;
- (void)deleteNode:(RSNode *)node;

- (void)connectOutToBus:(SCBus *)bus;
- (void)applyDictionaryRepresentation:(NSDictionary *)snapshot;

// Node ordering
- (BOOL)moveNode:(RSNode *)movingSynth 
      beforeNode:(RSNode *)synthToMoveBefore;
- (void)nodeDidSpawn:(RSNode *)aNode;

// Utility
- (void)trimInactiveNodesAndWires;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

// It's sometimes useful to use a graph with slightly different synthdefs
// e.g. replacing a pitch-generating ugen that's usually a buffer with a constant-value generator
// while editing the graph, and then putting it back when done
- (NSDictionary *)dictionaryRepresentationWithSynthDefReplacements:(NSDictionary *)replacementSynthDefNamesByNodeID;
- (void)replaceSynthDefsOfNodesByID:(NSDictionary *)replacementSynthDefNamesByNodeID;



#pragma mark - Testing
- (void)applyTestSnapshot;

@end
