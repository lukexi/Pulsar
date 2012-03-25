#import "RSInput.h"
#import "SCBus.h"
#import "SCSynth.h"
#import "RSNode.h"
#import "RSSynthDefControl.h"
#import "RSWire.h"
#import "RSGraph.h"

@interface RSInput ()

@property (nonatomic, strong, readwrite) SCBus *inputSummingBus;
@property (nonatomic, strong, readwrite) SCSynth *scalerNode;
@property (nonatomic, strong) SCSynth *dcNode;

@property (nonatomic, readwrite) BOOL isSpawned;

@end

@interface RSInput (Internal)

- (void)setupMap;

@property (nonatomic, readonly) NSTimeInterval lagTime;

- (NSString *)dcSynthName;
- (NSString *)scalerSynthName;

@end

@implementation RSInput
@synthesize inputSummingBus;
@synthesize scalerNode;
@synthesize dcNode;
@synthesize isSpawned;

- (NSString *)description
{
    if (self.isFault) 
    {
        return [super description];
    }
    return [NSString stringWithFormat:
            @"<%@ %p Center:%@ ModDepth:%@ InputSummingBusNumber:%i ScalerNodeID:%i DCNodeID:%i>", 
            [self class], self, self.center, self.modDepth, 
            inputSummingBus.busID, scalerNode.nodeID, dcNode.nodeID];
}

- (void)setModDepthValue:(float)aModDepth
{
    [super setModDepthValue:aModDepth];
    if (self.node.graph.isSpawned)
    {
        [self.scalerNode set:[NSArray arrayWithObjects:
                              [OSCValue createWithString:@"modDepth"], 
                              [OSCValue createWithFloat:self.modDepthValue], 
                              [OSCValue createWithString:@"t_lagTime"], 
                              [OSCValue createWithFloat:self.lagTime],
                              nil]];
    }
}

- (void)setCenterValue:(float)aCenter
{
    [super setCenterValue:aCenter];
    if (self.node.graph.isSpawned)
    {
        [self.scalerNode set:[NSArray arrayWithObjects:
                              [OSCValue createWithString:@"center"], 
                              [OSCValue createWithFloat:self.centerValue], 
                              [OSCValue createWithString:@"t_lagTime"], 
                              [OSCValue createWithFloat:self.lagTime],
                              nil]];
    }
}

- (void)spawn
{    
    self.inputSummingBus = [SCBus busWithChannels:1 
                                             rate:self.synthDefControl.rate];
    
    self.scalerNode = [SCSynth synthWithName:[self scalerSynthName]
                                   arguments:[NSArray arrayWithObjects:
                                              [OSCValue createWithString:@"inputSummingBus"], 
                                              [OSCValue createWithInt:self.inputSummingBus.busID],
                                              [OSCValue createWithString:@"center"], 
                                              [OSCValue createWithFloat:self.centerValue],
                                              [OSCValue createWithString:@"modDepth"], 
                                              [OSCValue createWithFloat:self.modDepthValue],
                                              nil]];
    self.scalerNode.target = self.node.inputConnectorGroup;
    self.scalerNode.addAction = SCAddToTailAction;
    [self.scalerNode send];
    
    self.dcNode = [SCSynth synthWithName:[self dcSynthName]
                               arguments:[NSArray arrayWithObjects:
                                          [OSCValue createWithString:@"inputSummingBus"],
                                          [OSCValue createWithInt:self.inputSummingBus.busID],
                                          nil]];
    self.dcNode.target = self.node.inputConnectorGroup;
    self.dcNode.addAction = SCAddToHeadAction;
    [self.dcNode send];
    
    [self setupMap];
    
    self.isSpawned = YES;
}

- (void)free
{
    [self.inputSummingBus free];
    
    if (self.node.isSpawned) 
    {
        [self.scalerNode free];
        [self.dcNode free];
    }
    
    self.isSpawned = NO;
}

@end

@implementation RSInput (Internal)

- (NSTimeInterval)lagTime
{
    return self.node.graph.lagTime;
}

- (NSString *)scalerSynthName
{
    return self.synthDefControl.rate == SCSynthAudioRate ? @"RSAudioMulAdd" : @"RSControlMulAdd";
}

- (NSString *)dcSynthName
{
    return self.synthDefControl.rate == SCSynthAudioRate ? @"RSAudioDC" : @"RSControlDC";
}

- (void)setupMap
{
    [self.node.synthNode map:self.synthDefControl.name 
                       toBus:self.inputSummingBus];
}

@end
