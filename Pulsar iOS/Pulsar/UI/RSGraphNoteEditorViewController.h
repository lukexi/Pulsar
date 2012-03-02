//
//  RSGraphNoteEditorViewController.h
//  Artikulator
//
//  Created by Luke Iannini on 9/6/11.
//  Copyright 2011 Eeoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSGraphNoteEditorViewController;
@protocol RSGraphNoteEditorViewControllerDelegate <NSObject>

- (void)noteEditorWillDismiss:(RSGraphNoteEditorViewController *)noteEditor;

@end

@interface RSGraphNoteEditorViewController : UIViewController

+ (RSGraphNoteEditorViewController *)graphNoteEditorViewControllerWithDelegate:(id <RSGraphNoteEditorViewControllerDelegate>)delegate;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet id <RSGraphNoteEditorViewControllerDelegate> delegate;
@end
