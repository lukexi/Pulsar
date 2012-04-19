#import "RSGraph.h"
#import "RSNode.h"
#import "RSSynthDef.h"
#import "RSWire.h"
#import "RSInput.h"
#import "RSOutNode.h"

#import "SCKit.h"
#import "NSArray+Additions.h"

#import "RSPresetParser.h"

@interface RSGraph ()

@property (nonatomic, strong, readwrite) SCGroup *graphGroup;
@property (nonatomic, strong) NSMutableArray *spawnedOrderedNodes;
@property (nonatomic, readwrite) BOOL isSpawned;

- (void)commonInit;
- (NSUInteger)countOfNodesWithSynthDef:(RSSynthDef *)synthDef;

@end

@implementation RSGraph
@synthesize graphGroup, superGroup;
@synthesize spawnedOrderedNodes;
@synthesize lagTime;
@synthesize dictionaryRepresentation;
@synthesize isSpawned;

- (NSString *)description
{
    if (self.isFault) 
    {
        return [super description];
    }
    
    NSString *IDs = [[self.spawnedOrderedNodes valueForKey:@"nodeID"] 
                     componentsJoinedByString:@">"];
    
    NSString *synthDefs = [[self.spawnedOrderedNodes valueForKeyPath:@"synthDef.name"] 
                           componentsJoinedByString:@">"];
    
    return [NSString stringWithFormat:@"<%@ %p Spawned:%@ GroupID:%i IDs:[%@] SynthDefs:[%@]>", 
            [self class], self, isSpawned ? @"YES" : @"NO", self.graphGroup.nodeID, IDs, synthDefs];
}

- (void)prepareForDeletion
{
    [self free];
    [super prepareForDeletion];
}

- (void)didTurnIntoFault
{
    [self free];
    [super didTurnIntoFault];
}

+ (id)graphFromDictionary:(NSDictionary *)dictionary 
                inContext:(NSManagedObjectContext *)context
{
    RSGraph *graph = [RSGraph insertInManagedObjectContext:context];
    [graph applyDictionaryRepresentation:dictionary];
    return graph;
}

+ (id)graphFromGraph:(RSGraph *)graphToCopy
           inContext:(NSManagedObjectContext *)context
{
    return [self graphFromDictionary:graphToCopy.dictionaryRepresentation 
                           inContext:context];
}

- (RSGraph *)graphCopy
{
    return [RSGraph graphFromGraph:self inContext:self.managedObjectContext];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self commonInit];
    
    self.outNode = [RSOutNode outNodeInContext:self.managedObjectContext];
    [self addNode:self.outNode];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self commonInit];
}

- (void)commonInit
{
    self.spawnedOrderedNodes = [NSMutableArray array];
}



- (RSNode *)addNodeWithID:(NSString *)nodeID fromSynthDefNamed:(NSString *)synthDefName
{
    RSSynthDef *synthDef = [RSSynthDef synthDefNamed:synthDefName inContext:self.managedObjectContext];
    RSNode *node = [RSNode nodeFromSynthDef:synthDef withID:nodeID];
    [self addNode:node];
    return node;
}

- (RSNode *)addNodeFromSynthDef:(RSSynthDef *)synthDef
{
    NSString *nodeID = [self nodeIDForNewNodeWithSynthDef:synthDef];
    RSNode *node = [RSNode nodeFromSynthDef:synthDef withID:nodeID];
    [self addNode:node];
    return node;
}

- (NSString *)nodeIDForNewNodeWithSynthDef:(RSSynthDef *)synthDef
{
    return [NSString stringWithFormat:@"%@%u", 
            synthDef.name, 
            [self countOfNodesWithSynthDef:synthDef]];
}

// Useful for automatically determining an ID for a new synthDef node
- (NSUInteger)countOfNodesWithSynthDef:(RSSynthDef *)synthDef
{
    NSUInteger count = 0;
    for (RSNode *node in self.nodes) 
    {
        if (node.synthDef == synthDef) 
        {
            count++;
        }
    }
    return count;
}

- (void)spawn
{
    self.graphGroup = [SCGroup groupSendLater:YES];
    self.graphGroup.target = self.superGroup;
    [self.graphGroup send];
    self.spawnedOrderedNodes = [NSMutableArray arrayWithCapacity:[self.nodes count]];
    
    // Make sure all nodes exist before trying to connect them together
    for (RSNode *node in self.nodes)
    {
        [node spawn];
    }
    
    for (RSNode *node in self.nodes) 
    {
        for (RSWire *wire in node.outWires) 
        {
            [wire spawn];
        }
    }
    
    [self.completionNode.synthNode completionBlock:^{
        [self free];
    }];
    
    self.isSpawned = YES;
}

- (void)free
{
    if (self.isSpawned) 
    {
        [self.completionNode.synthNode completionBlock:nil];
        
        // All our nodes should be in here, so this will free them too, but we still need to free their buses...
        [self.graphGroup free];
        
        self.isSpawned = NO;
        
        // We must call this after setting isSpawned to no, so that RSNodes don't try to free themselves again.
        for (RSNode *node in self.nodes) 
        {
            [node free];
        }
    }
}

- (RSWire *)connect:(NSString *)fromNodeID toAudioInputOf:(NSString *)toNodeID atAmp:(CGFloat)amp
{
    return [self connect:fromNodeID to:@"a_in" of:toNodeID atAmp:amp];
}

- (RSWire *)connect:(NSString *)fromNodeID to:(NSString *)inputName of:(NSString *)toNodeID atAmp:(CGFloat)amp
{
    return [RSWire wireFrom:self[fromNodeID] to:self[toNodeID][inputName] atAmp:amp];
}

- (RSWire *)connect:(NSString *)fromNodeID toGraphOutputAtAmp:(CGFloat)amp
{
    return [RSWire wireFrom:self[fromNodeID] to:self.outNode[@"a_in"] atAmp:amp];
}

- (void)setObject:(NSString *)object forKeyedSubscript:(NSString *)key
{
    [self addNodeWithID:key fromSynthDefNamed:object];
}

- (RSNode *)objectForKeyedSubscript:(id)key
{
    return [self nodeWithID:key];
}

- (RSNode *)nodeWithID:(NSString *)synthName
{
    for (RSNode *node in self.nodes) 
    {
        if ([node.nodeID isEqualToString:synthName]) 
        {
            return node;
        }
    }
    return nil;
}

- (void)addNode:(RSNode *)node
{
    [self addNodesObject:node];
    
    if (self.isSpawned) 
    {
        [node spawn];
    }
}

- (void)deleteNode:(RSNode *)node
{
    [self.spawnedOrderedNodes removeObject:node];
    [[self managedObjectContext] deleteObject:node];
    [[self managedObjectContext] processPendingChanges];
}

// Called by our RSNodes on spawn
- (void)nodeDidSpawn:(RSNode *)aNode
{
    [self.spawnedOrderedNodes addObject:aNode];
}

- (BOOL)moveNode:(RSNode *)movingSynth beforeNode:(RSNode *)synthToMoveBefore
{
    NSUInteger indexOfSynthToMoveBefore = [self.spawnedOrderedNodes indexOfObject:synthToMoveBefore];
    if ([self.spawnedOrderedNodes indexOfObject:movingSynth] < indexOfSynthToMoveBefore) 
    {
        // Synth is already before the other synth. Return NO to inform our asker that no move is necessary.
        return NO;
    }
    [self.spawnedOrderedNodes removeObject:movingSynth];
    [self.spawnedOrderedNodes insertObject:movingSynth atIndex:indexOfSynthToMoveBefore];
    return YES;
}

- (void)connectOutToBus:(SCBus *)bus
{
    self.outNode.outNodeOutputBus = bus;
}

- (void)replaceSynthDefsOfNodesByID:(NSDictionary *)replacementSynthDefNamesByNodeID
{
    NSDictionary *dictionary = [self dictionaryRepresentationWithSynthDefReplacements:replacementSynthDefNamesByNodeID];
    // The applyDictionaryRepresentation function skips nodes that already exist, so we remove them first so we can replace them
    for (NSString *nodeID in [replacementSynthDefNamesByNodeID allKeys]) 
    {
        [self deleteNode:[self nodeWithID:nodeID]];
    }
    
    [self applyDictionaryRepresentation:dictionary];
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryRepresentationWithSynthDefReplacements:nil];
}

- (NSDictionary *)dictionaryRepresentationWithSynthDefReplacements:(NSDictionary *)replacementSynthDefNamesByNodeID
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionary];
    
    NSMutableArray *synths = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    for (RSNode *node in self.nodes)
    {
        NSString *synthDefName = [replacementSynthDefNamesByNodeID objectForKey:node.nodeID] ?: node.synthDef.name;
        [synths addObject:[NSArray arrayWithObjects:node.nodeID, synthDefName, NSStringFromCGPoint(CGPointMake(node.xValue, node.yValue)), nil]];
        
        for (RSInput *input in node.inputs) 
        {
            NSString *centerKey = [NSString stringWithFormat:@"%@.%@.center", node.nodeID, input.synthDefControl.name];
            [params setObject:input.center forKey:centerKey];
            NSString *modKey = [NSString stringWithFormat:@"%@.%@.modDepth", node.nodeID, input.synthDefControl.name];
            [params setObject:input.modDepth forKey:modKey];
        }
        
        for (RSWire *wire in node.outWires) 
        {
            NSString *key = [NSString stringWithFormat:@"%@=>%@.%@", 
                             node.nodeID, 
                             wire.destinationInput.node.nodeID,
                             wire.destinationInput.synthDefControl.name];
            [params setObject:wire.amp forKey:key];
        }
    }
    
    [representation setObject:synths forKey:@"synths"];
    [representation setObject:params forKey:@"params"];
    if (self.completionNode) 
    {
        [representation setObject:self.completionNode.nodeID forKey:@"completionNodeID"];
    }
    
    if (self.name)
    {
        [representation setObject:self.name forKey:@"name"];
    }
    
    return representation;
}

// Initial arguments are for dynamically-created arguments (e.g. buffer numbers) to initial-rate ("i_...") controls
- (void)applyDictionaryRepresentation:(NSDictionary *)snapshot
{
    // Remove any nodes that aren't in the dictionary
    NSArray *nodeInstances = [snapshot objectForKey:@"synths"];
    NSMutableArray *nodeIDs = [NSMutableArray arrayWithCapacity:[nodeInstances count]];
    for (NSArray *nodeInstance in nodeInstances) 
    {
        [nodeIDs addObject:[nodeInstance objectAtIndex:0]];
    }
    NSSet *nodesCopy = [self.nodes copy];
    for (RSNode *node in nodesCopy) 
    {
        if (![nodeIDs containsObject:node.nodeID]) 
        {
            //PLog(kSC_DEBUG, @"Deleting node not found in the new dictionary: %@ (%@)", node.nodeID, node.synthDef.name);
            [self deleteNode:node];
        }
    }
    
    // Apply the snapshot
    [RSPresetParser parsePreset:snapshot createdSynth:^(NSString *nodeID, NSString *defName, CGPoint location) {
        // Don't recreate synths that already exist.
        if (![self nodeWithID:nodeID]) 
        {
            RSSynthDef *synthDef = [RSSynthDef synthDefNamed:defName inContext:self.managedObjectContext];
            RSNode *node = [RSNode nodeFromSynthDef:synthDef withID:nodeID];
            node.xValue = location.x;
            node.yValue = location.y;
            [self addNode:node];
            //PLog(kRS_DEBUG, @"Creating nodeID %@ with def %@", nodeID, defName);
        }
    } connectedSynth:^(NSString *sourceSynthName, NSString *destinationSynthName, NSString *destinationControlName, CGFloat amp) {
        RSNode *sourceNode = [self nodeWithID:sourceSynthName];
        RSNode *destinationNode = [self nodeWithID:destinationSynthName];
        
        NSString *controlName = destinationControlName ?: @"a_in";
        RSInput *input = [destinationNode controlNamed:controlName];
        
        [RSWire wireFrom:sourceNode to:input atAmp:amp];
        //PLog(kRS_DEBUG, @"Connecting %@ to %@", sourceNode.synthDef.name, controlName);
        
    } setSynthControl:^(NSString *synthName, NSString *controlName, NSString *metaName, CGFloat amp) {
        RSNode *synth = [self nodeWithID:synthName];
        RSInput *input = [synth controlNamed:controlName];
        if ([metaName isEqualToString:@"center"])
        {
            [input setCenterValue:amp];
        }
        else if ([metaName isEqualToString:@"modDepth"])
        {
            [input setModDepthValue:amp];
        }
        //PLog(kRS_DEBUG, @"Setting %@.%@.%@ to %f", synth.synthDef.name, controlName, metaName, amp);
    }];
    self.completionNode = [self nodeWithID:[snapshot objectForKey:@"completionNodeID"]];
}

- (void)trimInactiveNodesAndWires
{
    for (RSNode *node in self.nodes) 
    {
        if (node == self.outNode) 
        {
            continue;
        }
        BOOL nodeIsActive = NO;
        for (RSWire *wire in node.outWires) 
        {
            if (wire.ampValue > 0)
            {
                nodeIsActive = YES;
            }
            else
            {
                //NSLog(@"Deleting wire during trimming from %@ to %@", wire.sourceNode, wire.destinationInput);
                [[self managedObjectContext] deleteObject:wire];
            }
        }
        if (!nodeIsActive) 
        {
            [[self managedObjectContext] deleteObject:node];
        }
    }
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) 
    {
        //PLog(kSC_DEBUG, @"Error saving trimming of graph %@: %@", self.name, error);
    }
}

#pragma mark debugging
- (void)applyTestSnapshot
{
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"Snapshot" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:path];
    NSError *error;
    NSDictionary *snapshot = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!snapshot) 
    {
        NSLog(@"Error loading Snapshot json: %@", error);
        return;
    }
    
    [self applyDictionaryRepresentation:snapshot];
    
    SCBuffer *pitchBuffer = [SCBuffer bufferWithCapacity:10];
    SCBuffer *durationBuffer = [SCBuffer bufferWithCapacity:9];
    
    float pitches[] = {440, 550, 200, 4000, 2000, 2500, 880, 990, 330, 660};
    [pitchBuffer setSamples:[NSArray lx_arrayWithFloats:pitches length:LXNumOf(pitches)]];
    
    float durations[] = {0.9f,0.9f,0.9f,0.9f,0.9f,0.9f,0.9f,0.9f,0.9f};
    [durationBuffer setSamples:[NSArray lx_arrayWithFloats:durations length:LXNumOf(durations)]];
    
    [self nodeWithID:@"PitchEnvGen"].initialArguments = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithInt:pitchBuffer.bufferNumber], 
                                                         @"i_pitchBufferNumber",
                                                         [NSNumber numberWithInt:durationBuffer.bufferNumber],
                                                         @"i_durationBufferNumber",
                                                         nil];
    [self nodeWithID:@"OutEnvelope"].initialArguments = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithInt:9],
                                                         @"i_duration",
                                                         [NSNumber numberWithFloat:0.3f],
                                                         @"i_fadeTime",
                                                         nil];
    
    [self spawn];
}

@end
