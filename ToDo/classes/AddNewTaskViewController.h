//
//  AddNewTaskViewController.h
//  ToDo
//
//  Created by James Gilmartin on 26/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>
#import "UIView+FindFirstResponder.h"

@interface AddNewTaskViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) DBDatastore *datastore;
@property (strong, nonatomic) NSDate *deadline;
@property (assign, nonatomic) CGPoint originalCenter;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UISlider *completionSlider;
@property (weak, nonatomic) IBOutlet UILabel *completionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *deadlineTextField;
@property (weak, nonatomic) IBOutlet UIButton *deadlineClearButton;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

- (IBAction)saveNewTask:(id)sender;
- (IBAction)cancelNewTask:(id)sender;
- (IBAction)textFieldDidChange:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)clearDeadline:(id)sender;

@end
