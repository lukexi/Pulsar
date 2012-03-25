#import "_RSNode.h"
#import "SCKit.h"
#import "RSServerObject.h"

@interface RSNode : _RSNode <RSServerObject> {}

@property (nonatomic, strong, readonly) SCGroup *containerGroup;
@property (nonatomic, strong, readonly) SCGroup *inputConnectorGroup;
@property (nonatomic, strong, readonly) SCSynth *synthNode;
@property (nonatomic, strong, readonly) SCBus *outputBus;

@property (nonatomic, strong) NSDictionary *initialArguments;

+ (id)nodeFromSynthDef:(RSSynthDef *)synthDef 
                withID:(NSString *)nodeID;

- (RSInput *)controlNamed:(NSString *)controlName;

- (void)orderBefore:(RSNode *)toNode;

@property (nonatomic, strong, readonly) NSArray *inputNames;

// New subscript support
- (RSInput *)objectForKeyedSubscript:(id)key;

@end