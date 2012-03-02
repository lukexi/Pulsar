#import "RSNode.h"
#import "RSSynthDef.h"
#import "RSInput.h"
#import "RSWire.h"
#import "RSGraph.h"
#import "NSDictionary+OSCAdditions.h"

@interface RSNode ()

- (void)setupWithSynthDef:(RSSynthDef *)aSynthDef;

@property (nonatomic, strong, readwrite) SCGroup *containerGroup;
@property (nonatomic, strong, readwrite) SCGroup *inputConnectorGroup;
@property (nonatomic, strong, readwrite) SCSynth *synthNode;
@property (nonatomic, strong, readwrite) SCBus *outputBus;

@property (nonatomic, readwrite) BOOL isSpawned;

@end


@interface RSNode (Internal)

- (void)setupSynths;
- (void)setupControls;
- (void)spawnSynthNode;

- (NSArray *)initialArgumentsIncludingOutputBus;

- (void)orderBefore:(RSNode *)toNode originatingNode:(RSNode *)originatingNode;

@end

@implementation RSNode
@synthesize containerGroup;
@synthesize inputConnectorGroup;
@synthesize synthNode;
@synthesize outputBus;
@synthesize isSpawned;
@synthesize initialArguments;
// Private

- (void)prepareForDeletion
{
    [self free];
    [super prepareForDeletion];
}

- (NSString *)description
{
    if (self.isFault) 
    {
        return [super description];
    }
    NSString *inputNames = [[[self.inputs allObjects] valueForKeyPath:@"synthDefControl.name"] componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"<%@ %p \n\tID:%@ \n\tSynthDef:%@ \n\tPosition:{%@, %@} \n\tContainerGroup:%@ \n\tInputConnectorGroup:%@ \n\tSynthNode:%@, \n\tOutputBus:%@ \n\tInputs:[%@]\n>", [self class], self, 
            self.nodeID, self.synthDef.name, self.x, self.y, self.containerGroup, self.inputConnectorGroup, self.synthNode, self.outputBus, inputNames];
}

+ (id)nodeFromSynthDef:(RSSynthDef *)synthDef 
                withID:(NSString *)nodeID 
{
    RSNode *node = [[self class] insertInManagedObjectContext:synthDef.managedObjectContext];
    node.nodeID = nodeID;
    [node setupWithSynthDef:synthDef];
    
    return node;
}

- (void)setupWithSynthDef:(RSSynthDef *)aSynthDef
{
    self.synthDef = aSynthDef;
    
    for (RSSynthDefControl *control in self.synthDef.controls)
    {
        RSInput *input = [RSInput insertInManagedObjectContext:self.managedObjectContext];
        input.synthDefControl = control;
        input.node = self;
        input.centerValue = control.defaultValue;
    }
}

- (NSArray *)inputNames
{
    return [[[self.inputs valueForKeyPath:@"synthDefControl.name"] allObjects] 
            sortedArrayUsingSelector:@selector(compare:)];
}

- (RSInput *)controlNamed:(NSString *)controlName
{
    for (RSInput *input in self.inputs) 
    {
        if ([input.synthDefControl.name isEqualToString:controlName]) 
        {
            return input;
        }
    }
    
    return nil;
}

- (void)orderBefore:(RSNode *)toNode
{
    [self orderBefore:toNode originatingNode:self];
}

#pragma mark - RSServerObject
- (void)spawn
{
    [self setupSynths];
    [self setupControls];
    self.isSpawned = YES;
    [self.graph nodeDidSpawn:self];
}

- (void)free
{
    //NSLog(@"Freeing node %@", self.synthDef.name);
    if (self.graph.isSpawned) 
    {
        //NSLog(@"Graph is spawned, so freeing node's %@ group %@", self.synthDef.name, self.containerGroup);
        // This frees input synths automatically, as they're in this group.
        [self.containerGroup free];
    }
    
    // We set isSpawned to NO /before/ freeing our children, because freeing our containerGroup implicitly means we're now 'free'.
    self.isSpawned = NO;
    
    for (RSInput *input in self.inputs)
    {
        //NSLog(@"Freeing input %@", input.synthDefControl.name);
        // We need to free the inputs' buses.
        [input free];
    }
    
    //NSLog(@"Freeing output bus %@", self.outputBus);
    [self.outputBus free];
    
    // upon deletion of this node, any connected RSWires will be cascade-deleted too,
    // which triggers their own free method (if the graph is running).
}

@end

@implementation RSNode (Internal)

- (void)setupSynths
{
    self.outputBus = [SCBus busWithChannels:1 rate:self.synthDef.outputRate];
    
    self.containerGroup = [SCGroup groupSendLater:YES];
    self.containerGroup.target = self.graph.graphGroup;
    self.containerGroup.addAction = SCAddToTailAction;
    [self.containerGroup send];
    
    self.inputConnectorGroup = [SCGroup groupSendLater:YES];
    self.inputConnectorGroup.target = self.containerGroup;
    self.inputConnectorGroup.addAction = SCAddToHeadAction;
    [self.inputConnectorGroup send];
    
    [self spawnSynthNode];
}

- (void)setupControls
{
    for (RSInput *input in self.inputs) 
    {
        [input spawn];
    }
}

- (void)spawnSynthNode
{
    self.synthNode = [SCSynth synthWithName:self.synthDef.name 
                                  arguments:[self initialArgumentsIncludingOutputBus]];
    self.synthNode.target = self.containerGroup;
    self.synthNode.addAction = SCAddToTailAction;
    [self.synthNode send];
}

- (NSArray *)initialArgumentsIncludingOutputBus
{
    NSArray *argumentsAsArray = [self.initialArguments sc_asOSCArgsArray] ?: [NSArray array];
    NSArray *argumentsIncludingOutBus = [argumentsAsArray arrayByAddingObjectsFromArray:
                                         [NSArray arrayWithObjects:
                                          [OSCValue createWithString:@"i_out"], 
                                          [OSCValue createWithInt:self.outputBus.busID], 
                                          nil]];
    return argumentsIncludingOutBus;
}

- (void)orderBefore:(RSNode *)toNode originatingNode:(RSNode *)originatingNode
{
    /* We must check if we're already before toNode before moving — otherwise we risk
     disrupting a previous ordering structure.
     E.g.:
     [A,B,C]>D------>O
     [X,Y]>Z>O
     (i.e. order is [A,B,C,D,X,Y,Z,O])
     If we connect C to Z and always orderedBefore, C would get moved before Z, 
     but after D, breaking C's connection to D.
     */
    if (![self.graph moveNode:self beforeNode:toNode])
    {
        //PLog(kRS_DEBUG, @"%@ is already before %@. Not moving.", self.nodeID, toNode.nodeID);
        return;
    }
    //PLog(kRS_DEBUG, @"Moving %@ before %@", self.nodeID, toNode.nodeID);
    
    [self.containerGroup moveBefore:toNode.containerGroup];
    
    for (RSInput *input in self.inputs) 
    {
        for (RSWire *wire in input.wires)
        {
            RSNode *incomingNode = wire.sourceNode;
            if (incomingNode == originatingNode) 
            {
                //PLog(kRS_DEBUG, @"Infinite loop detected — implement InFeedback to handle!");
                return;
            }
            
            [incomingNode orderBefore:self originatingNode:originatingNode];
        }
    }
}

@end