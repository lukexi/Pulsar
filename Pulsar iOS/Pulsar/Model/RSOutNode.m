#import "RSOutNode.h"
#import "RSGraph.h"
#import "RSSynthDef.h"

@interface RSOutNode ()

@property (nonatomic, strong) SCSynth *outConnectorNode;

@end

@implementation RSOutNode
@synthesize outNodeOutputBus=_outNodeOutputBus;
@synthesize outConnectorNode=_outConnectorNode;

+ (id)outNodeInContext:(NSManagedObjectContext *)context
{
    RSSynthDef *outSynthDef = [RSSynthDef synthDefNamed:@"Out" 
                                              inContext:context];
    return [RSOutNode nodeFromSynthDef:outSynthDef withID:@"Out"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setup];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self setup];
}

- (void)setup
{
    // Not automatically connecting RSGraphs to mainOutputBus for now, because I'm exploring
    // an RSWire-based approach for connecting RSGraphs together (e.g. SDCreatureSounds being
    // connected to SDWorldSounds).
    //self.outNodeOutputBus = [SCBus mainOutputBus];
}

- (void)setOutNodeOutputBus:(SCBus *)outNodeOutputBus
{
    _outNodeOutputBus = outNodeOutputBus;
    if (self.graphAsOut.isSpawned)
    {
        [self.outConnectorNode free];
        [self spawnOutputConnector];
    }
}

- (void)spawn
{
    [super spawn];
    [self spawnOutputConnector];
}

- (void)spawnOutputConnector
{
    if (!self.outNodeOutputBus)
    {
        return;
    }
    // Can currently only connect to one output bus at a time.
    // To support more, just make outConnectorNode(s) an array of RSAudioConnectors.
    
    // RSGraphs are currently mono, so if we connect to a stereo bus (like the out bus), we use a connector that
    // duplicates the signal to both channels
    NSString *connectorName = self.outNodeOutputBus.numberOfChannels == 2 ? @"RSAudioConnectorMonoToStereo" : @"RSAudioConnector";
    self.outConnectorNode = [SCSynth synthWithName:connectorName
                                         arguments:[NSArray arrayWithObjects:
                                                    [OSCValue createWithString:@"fromBus"],
                                                    [OSCValue createWithInt:self.outputBus.busID],
                                                    [OSCValue createWithString:@"toBus"],
                                                    [OSCValue createWithInt:self.outNodeOutputBus.busID],
                                                    [OSCValue createWithString:@"amp"],
                                                    [OSCValue createWithFloat:1],
                                                    nil]];
    self.outConnectorNode.target = self.containerGroup;
    self.outConnectorNode.addAction = SCAddToTailAction;
    [self.outConnectorNode send];
}

@end