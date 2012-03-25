#import "_RSGraph.h"
#import "RSServerObject.h"

@class SCBus;
@class SCGroup;
@class RSOutNodeInstance;
@class RSSynthDef;
@class RSWire;

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
// Finds and deletes any nodes whose output wires all have an amplitude of 0
- (void)trimInactiveNodesAndWires;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

// It's sometimes useful to use a graph with slightly different synthdefs
// e.g. replacing a pitch-generating ugen that's usually a buffer with a constant-value generator
// while editing the graph, and then putting it back when done
- (void)replaceSynthDefsOfNodesByID:(NSDictionary *)replacementSynthDefNamesByNodeID;

- (NSDictionary *)dictionaryRepresentationWithSynthDefReplacements:(NSDictionary *)replacementSynthDefNamesByNodeID;

// New subscript support
- (RSNode
   *)objectForKeyedSubscript:(id)key;
// Object is string name of a synthdef, key becomes node ID
- (void)setObject:(NSString *)object forKeyedSubscript:(NSString *)key;

// Testing syntax
- (RSWire *)connect:(NSString *)fromNodeID toAudioInputOf:(NSString *)toNodeID atAmp:(CGFloat)amp;
- (RSWire *)connect:(NSString *)fromNodeID to:(NSString *)inputName of:(NSString *)toNodeID atAmp:(CGFloat)amp;
- (RSWire *)connect:(NSString *)fromNodeID toGraphOutputAtAmp:(CGFloat)amp;

#pragma mark - Testing
- (void)applyTestSnapshot;

@end
