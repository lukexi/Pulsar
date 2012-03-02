//
//  SCRoutableSynthEditorViewController.m
//  Artikulator
//
//  Created by Luke Iannini on 8/30/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import "RSGraphEditorViewController.h"
#import "RSPresetParser.h"
#import "RSGraph.h"
#import "RSNode.h"
#import "RSInput.h"
#import "RSWire.h"
#import "RSSynthDef.h"
#import "RSUGenListViewController.h"
#import "RSGraphListViewController.h"
#import "RSGraphNoteEditorViewController.h"
#import "RSNodeControlInlet.h"
#import "NKNodeOutlet.h"
#import "NKOutNodeView.h"
#import "NKOutNodeInlet.h"
#import "NKNodeCanvasView.h"

@interface RSGraphEditorViewController ()
<
    NKNodeCanvasViewDelegate, 
    RSUGenListViewControllerDelegate, 
    RSGraphListViewControllerDelegate, 
    UITextFieldDelegate, 
    UIPopoverControllerDelegate, 
    RSGraphNoteEditorViewControllerDelegate,
    NKNodeCanvasViewDataSource,
    RSNodeControlInletDelegate
>
{
    
}

@property (nonatomic, strong) UIPopoverController *currentPopoverController;
- (void)dismissCurrentPopoverController;

@end

@implementation RSGraphEditorViewController
@synthesize delegate;
@synthesize nodeCanvasView;
@synthesize titleField;
@synthesize currentPopoverController;
@synthesize currentGraph;
@synthesize managedObjectContext;

- (void)dealloc 
{
    [currentGraph free];
}

+ (id)routableSynthEditorViewControllerWithDelegate:(id <RSGraphEditorViewControllerDelegate>)delegate
{
    RSGraphEditorViewController *editor = [[self alloc] initWithNibName:nil bundle:nil];
    editor.delegate = delegate;
    return editor;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    RSGraph *graph = [RSGraph defaultGraphInContext:[AKMainContext mainContext]];
//    [self loadGraph:graph];
}

- (void)viewDidUnload
{
    [self setTitleField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissCurrentPopoverController];
}

#pragma mark - Loading snapshots

// Override to provide if desired
- (void)applyInitialArgumentsToPreviewGraph
{
    
}

- (void)loadGraph:(RSGraph *)graph
{
    self.titleField.text = graph.name;
    
    [self.nodeCanvasView removeAllNodes];
    
    RSGraph *previousGraph = self.currentGraph;
    self.currentGraph = graph;
    [SCBundle bundleMessages:^(void) {
        [previousGraph free];
        [self applyInitialArgumentsToPreviewGraph];
        [self.currentGraph spawn];
        [self.currentGraph connectOutToBus:[SCBus mainOutputBus]];
    }];
    
    for (RSNode *node in graph.nodes) 
    {        
        CGPoint nodePoint = CGPointMake(node.xValue, node.yValue);
        if (CGPointEqualToPoint(nodePoint, CGPointZero)) 
        {
            nodePoint = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
        }
        nodePoint.x = MAX(0, MIN(self.view.bounds.size.width, nodePoint.x));
        nodePoint.y = MAX(0, MIN(self.view.bounds.size.height, nodePoint.y));
        [self.nodeCanvasView addNodeWithID:node.nodeID 
                                   atPoint:nodePoint 
                                  animated:NO];
    }
    
    for (RSNode *node in graph.nodes) 
    {
        for (RSWire *wire in node.outWires) 
        {
            [self.nodeCanvasView connectOutletNamed:@"Out" 
                                       ofNodeWithID:wire.sourceNode.nodeID 
                                       toInletNamed:wire.destinationInput.synthDefControl.name 
                                       ofNodeWithID:wire.destinationInput.node.nodeID
                                              atAmp:wire.ampValue];
        }
        
        NSString *nodeID = node.nodeID;
        NKNodeView *nodeView = [self.nodeCanvasView nodeViewWithID:nodeID];
        for (RSInput *input in node.inputs) 
        {
            RSSynthDefControl *control = input.synthDefControl;
            NSString *inputName = control.name;
            
            RSNodeControlInlet *inlet = (RSNodeControlInlet *)[nodeView inletNamed:inputName];
            if ([inlet isKindOfClass:[RSNodeControlInlet class]]) 
            {
//                inlet.centerValue = [control.spec unmap:input.centerValueValue];
//                inlet.modValue = [control.spec unmap:input.modDepthValue];
                inlet.centerValue = input.centerValueValue;
                inlet.modValue = input.modDepthValue;
            }
        }
    }
}

#pragma mark - IBActions

- (IBAction)addNodeAction:(id)sender 
{
    if (self.currentPopoverController) 
    {
        [self dismissCurrentPopoverController];
    }
    else
    {
        self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:[RSUGenListViewController UGenListViewControllerWithDelegate:self context:self.managedObjectContext]];
        self.currentPopoverController.delegate = self;
        [self.currentPopoverController presentPopoverFromBarButtonItem:sender 
                                              permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                              animated:YES];
    }
}

- (IBAction)loadGraphAction:(id)sender
{
    if (self.currentPopoverController) 
    {
        [self dismissCurrentPopoverController];
    }
    else
    {
        RSGraphListViewController *graphList = [RSGraphListViewController graphListViewControllerWithDelegate:self context:self.managedObjectContext inNavController:YES];
        self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:graphList];
        self.currentPopoverController.delegate = self;
        [self.currentPopoverController presentPopoverFromBarButtonItem:sender 
                                              permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                              animated:YES];
    }
}

- (void)dismissCurrentPopoverController
{
    [self.currentPopoverController dismissPopoverAnimated:YES];
    self.currentPopoverController = nil;
}

- (IBAction)doneAction:(id)sender 
{
    [self save];
    [self.delegate routableSynthEditorDidFinish:self];
}

- (void)save
{
    NSError *error;
    BOOL success = [self.managedObjectContext save:&error];
    if (!success) 
    {
        NSLog(@"Error saving current graph: %@", error);
    }
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.currentPopoverController = nil;
}

#pragma mark - RSUGenListViewControllerDelegate
- (void)UGenList:(RSUGenListViewController *)listViewController didSelectUGen:(RSSynthDef *)synthDef
{
    NSString *nodeID = [self.currentGraph addNodeFromSynthDef:synthDef].nodeID;
    
    [self.nodeCanvasView addNodeInCenterWithID:nodeID
                                      animated:YES];
    
    [self dismissCurrentPopoverController];
}

#pragma mark - RSGraphListViewControllerDelegate

-(void)graphList:(RSGraphListViewController *)graphList didCreateGraph:(RSGraph *)graph
{
    [self graphList:graphList didSelectGraph:graph];
}

-(void)graphList:(RSGraphListViewController *)graphList didSelectGraph:(RSGraph *)graph
{
    [self loadGraph:graph];
    [self dismissCurrentPopoverController];
}

#pragma mark - NKNodeCanvasViewDelegate

- (void)nodeCanvas:(NKNodeCanvasView *)aNodeCanvas 
connectedOutletNamed:(NSString *)outletName 
      ofNodeWithID:(NSString *)outletParentNodeID 
      toInletNamed:(NSString *)inletName 
      ofNodeWithID:(NSString *)inletParentNodeID
{
    // RoutableSynth doesn't support multiple outlets yet, so we don't use the "outletName" param yet
    RSNode *sourceSynth = [self.currentGraph nodeWithID:outletParentNodeID];
    RSNode *destinationSynth = [self.currentGraph nodeWithID:inletParentNodeID];
    RSInput *input = [destinationSynth controlNamed:inletName];
    [RSWire wireFrom:sourceSynth to:input atAmp:1];
    
    [self save];
}

- (void)nodeCanvas:(NKNodeCanvasView *)aNodeCanvas 
disconnectedOutletNamed:(NSString *)outletName 
      ofNodeWithID:(NSString *)outletParentNodeID
    fromInletNamed:(NSString *)inletName
      ofNodeWithID:(NSString *)inletParentNodeID
{
    RSNode *sourceSynth = [self.currentGraph nodeWithID:outletParentNodeID];
    RSNode *destinationSynth = [self.currentGraph nodeWithID:inletParentNodeID];
    
    RSWire *wire = [RSWire existingWireFrom:sourceSynth to:[destinationSynth controlNamed:inletName]];
    [wire.managedObjectContext deleteObject:wire];
}

- (void)nodeCanvas:(NKNodeCanvasView *)aNodeCanvas 
removedNodeWidthID:(NSString *)nodeID
{
    [self.currentGraph deleteNode:[self.currentGraph nodeWithID:nodeID]];
    
    [self save];
}

- (void)nodeCanvas:(NKNodeCanvasView *)aNodeCanvas 
connectionOfOutletNamed:(NSString *)outletName
      ofNodeWithID:(NSString *)outletParentNodeID
      toInletNamed:(NSString *)inletName
      ofNodeWithID:(NSString *)inletParentNodeID
    didChangeAmpTo:(CGFloat)amp
{
    RSNode *sourceNode = [self.currentGraph nodeWithID:outletParentNodeID];
    RSInput *destinationInput = [[self.currentGraph nodeWithID:inletParentNodeID] controlNamed:inletName];
    
    [[RSWire existingWireFrom:sourceNode to:destinationInput] setAmpValue:amp];
    
    [self save];
}

- (void)nodeCanvas:(NKNodeCanvasView *)aNodeCanvas 
   movedNodeWithID:(NSString *)nodeID 
           toPoint:(CGPoint)point
{
    [self.currentGraph nodeWithID:nodeID].xValue = point.x;
    [self.currentGraph nodeWithID:nodeID].yValue = point.y;
    
    [self save];
}

#pragma mark - NKNodeCanvasViewDataSource

- (NKNodeView *)nodeCanvas:(NKNodeCanvasView *)aNodeCanvas nodeViewForNodeWithID:(NSString *)nodeID
{
    RSNode *node = [self.currentGraph nodeWithID:nodeID];
    NSArray *inputNames = node.inputNames;
    Class nodeViewClass = [node isEqual:self.currentGraph.outNode] ? [NKOutNodeView class] : [NKNodeView class];
    
    return [nodeViewClass nodeWithID:nodeID
                                name:node.synthDef.name
                          inletNames:inputNames
                          dataSource:self];
}

- (NKWireView *)nodeCanvas:(NKNodeCanvasView *)aNodeCanvas
wireForConnectionFromOutletNamed:(NSString *)outletName
              ofNodeWithID:(NSString *)inletParentNodeID
              toInletNamed:(NSString *)inletName
              ofNodeWithID:(NSString *)outletParentNodeID
{
    // TODO finish datasourcing NKWireViews
    return nil;
}

- (NKNodeInlet *)nodeView:(NKNodeView *)nodeView inletForInletNamed:(NSString *)inletName ofNodeWithID:(NSString *)nodeID
{
    RSNode *node = [self.currentGraph nodeWithID:nodeID];
    RSInput *control = [node controlNamed:inletName];
    
    if ([node isEqual:self.currentGraph.outNode])
    {
        return [NKOutNodeInlet XLetForNode:nodeView];
    }
    
    RSNodeControlInlet *inlet = [RSNodeControlInlet nodeControlInletWithName:inletName 
                                                                    modValue:control.modDepthValue 
                                                                 centerValue:control.centerValueValue 
                                                                    delegate:self
                                                                  inNodeView:nodeView];
    inlet.units = control.synthDefControl.units;
    inlet.range = NSMakeRange(control.synthDefControl.rangeLowValue, 
                              control.synthDefControl.rangeHighValue - control.synthDefControl.rangeLowValue);
    return inlet;
}

- (NKNodeOutlet *)nodeView:(NKNodeView *)nodeView outletForOutletNamed:(NSString *)outletName ofNodeWithID:(NSString *)nodeID
{
    return [NKNodeOutlet XLetForNode:nodeView];
}

- (CGSize)nodeViewSizeForInlets:(NKNodeView *)nodeView
{
    return [RSNodeControlInlet XLetSize];
}

- (CGSize)nodeViewSizeForOutlets:(NKNodeView *)nodeView
{
    return [NKNodeOutlet XLetSize];
}

#pragma mark RSNodeControlInletDelegate
- (void)nodeControlInlet:(RSNodeControlInlet *)nodeControlInlet didChangeMod:(CGFloat)modValue
{
    RSInput *input = [[self.currentGraph nodeWithID:nodeControlInlet.parentNode.nodeID] controlNamed:nodeControlInlet.name];
    input.modDepthValue = modValue;
}

- (void)nodeControlInlet:(RSNodeControlInlet *)nodeControlInlet didChangeCenter:(CGFloat)centerValue
{
    RSInput *input = [[self.currentGraph nodeWithID:nodeControlInlet.parentNode.nodeID] controlNamed:nodeControlInlet.name];
    input.centerValueValue = centerValue;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.titleField selectAll:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.currentGraph.name = textField.text;
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)editNotesAction:(id)sender 
{
    RSGraphNoteEditorViewController *noteEditor = [RSGraphNoteEditorViewController graphNoteEditorViewControllerWithDelegate:self];
    noteEditor.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [noteEditor view];
    noteEditor.textView.text = self.currentGraph.notes;
    
    [self presentModalViewController:noteEditor animated:YES];
    
//    PDo(kSC_DEBUG, ^{[self.currentGraph.graphGroup dumpTree];});
}

#pragma mark - RSGraphNoteEditorViewControllerDelegate

- (void)noteEditorWillDismiss:(RSGraphNoteEditorViewController *)noteEditor
{
    self.currentGraph.notes = noteEditor.textView.text;
    [self save];
}

@end
