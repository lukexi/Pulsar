#import "RSOutNode.h"
#import "RSGraph.h"
#import "RSSynthDef.h"

@interface RSOutNode ()

@property (nonatomic, strong) SCSynth *outConnectorNode;

@end

@implementation RSOutNode
@synthesize outConnectorNode;


+ (id)outNodeInContext:(NSManagedObjectContext *)context
{
    RSSynthDef *outSynthDef = [RSSynthDef synthDefNamed:@"Out" 
                                              inContext:context];
    return [RSOutNode nodeFromSynthDef:outSynthDef withID:@"Out"];
}

- (void)connectToMainOutput
{
    [self connectToBus:[SCBus mainOutputBus]];
}

- (void)connectToBus:(SCBus *)externalBus
{
#warning disabling this, think about more later. if node is already freed and reused, this just causes a random node to get freed :P
//    // Can currently only connect to one output bus at a time. To support more, just make outConnectorNode(s) an array of RSAudioConnectors
//    [self.outConnectorNode free];
    // RSGraphs are currently mono, so if we connect to a stereo bus (like the out bus), we use a connector that
    // duplicates the signal to both channels
    NSString *connectorName = externalBus.numberOfChannels == 2 ? @"RSAudioConnectorMonoToStereo" : @"RSAudioConnector";
    self.outConnectorNode = [SCSynth synthWithName:connectorName
                                         arguments:[NSArray arrayWithObjects:
                                                    [OSCValue createWithString:@"fromBus"],
                                                    [OSCValue createWithInt:self.outputBus.busID],
                                                    [OSCValue createWithString:@"toBus"],
                                                    [OSCValue createWithInt:externalBus.busID],
                                                    [OSCValue createWithString:@"amp"],
                                                    [OSCValue createWithFloat:1],
                                                    nil]];
    self.outConnectorNode.target = self.containerGroup;
    self.outConnectorNode.addAction = SCAddToTailAction;
    [self.outConnectorNode send];
}

@end