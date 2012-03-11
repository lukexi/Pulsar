#import "RSWire.h"
#import "SCKit.h"
#import "RSInput.h"
#import "RSNode.h"
#import "RSGraph.h"
#import "RSSynthDef.h"

@interface RSWire ()

@property (nonatomic, strong) SCSynth *connectorNode;
@property (nonatomic, readwrite) BOOL isSpawned;

- (NSString *)connectorSynthDefName;

@end

@implementation RSWire
@synthesize connectorNode;
@synthesize isSpawned;

+ (RSWire *)existingWireFrom:(RSNode *)sourceNode to:(RSInput *)destinationInput
{
    for (RSWire *wire in sourceNode.outWires) 
    {
        if (wire.sourceNode == sourceNode && wire.destinationInput == destinationInput) 
        {
            return wire;
        }
    }
    return nil;
}

+ (RSWire *)wireFrom:(RSNode *)sourceNode to:(RSInput *)destinationInput atAmp:(CGFloat)amp
{
    // Don't create two wires with the same source/destination. Update the existing one instead.
    RSWire *existingWire = [self existingWireFrom:sourceNode to:destinationInput];
    if (existingWire) 
    {
        existingWire.ampValue = amp;
        return existingWire;
    }
    
    RSWire *wire = [RSWire insertInManagedObjectContext:[sourceNode managedObjectContext]];
    wire.ampValue = amp;
    wire.sourceNode = sourceNode;
    wire.destinationInput = destinationInput;
    
    if (sourceNode.graph.isSpawned) 
    {
        [wire spawn];
    }
    
    return wire;
}


- (void)prepareForDeletion
{
    [super prepareForDeletion];
    [self free];
}

-(void)setAmpValue:(float)value_
{
    [super setAmpValue:value_];
    [self.connectorNode set:[NSArray arrayWithObjects:
                             [OSCValue createWithString:@"amp"],
                             [OSCValue createWithFloat:self.ampValue], 
                             [OSCValue createWithString:@"t_lagTime"], 
                             [OSCValue createWithFloat:self.destinationInput.node.graph.lagTime],
                             nil]];
}

- (void)free
{
    // Only free the wire's connectorNode if the graph is still running when the wire is deleted.
    // The graph will free the wire's connectorNode when it frees its group.
    if (self.destinationInput.node.isSpawned)
    {
        [self.connectorNode free];
        self.connectorNode = nil;
    }
    
    self.isSpawned = NO;
}

- (void)spawn
{
    [self.sourceNode orderBefore:self.destinationInput.node];
    
    self.connectorNode = [SCSynth synthWithName:[self connectorSynthDefName] 
                                      arguments:[NSArray arrayWithObjects:
                                                 [OSCValue createWithString:@"fromBus"], 
                                                 [OSCValue createWithInt:self.sourceNode.outputBus.busID],
                                                 [OSCValue createWithString:@"toBus"],
                                                 [OSCValue createWithInt:self.destinationInput.inputSummingBus.busID],
                                                 [OSCValue createWithString:@"amp"],
                                                 [OSCValue createWithFloat:self.ampValue],
                                                 nil]];
    self.connectorNode.target = self.destinationInput.node.inputConnectorGroup;
    self.connectorNode.addAction = SCAddToHeadAction;
    [self.connectorNode send];
    
    self.isSpawned = YES;
}

- (NSString *)connectorSynthDefName
{
    // self.destinationInput.synthDefControl.rate
    return self.sourceNode.synthDef.outputRate == SCSynthAudioRate ? 
        @"RSAudioConnector" : 
        @"RSControlConnector";
}

@end
