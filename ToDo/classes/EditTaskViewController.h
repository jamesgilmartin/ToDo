//
//  EditTaskViewController.h
//  ToDo
//
//  Created by James Gilmartin on 26/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface EditTaskViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) DBRecord *recordToEdit;
@property (strong, nonatomic) DBDatastore *datastore;
@property (strong, nonatomic) NSDate *deadline;
@property (assign, nonatomic) BOOL recordWasModified;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelEditButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveChangesButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UISlider *completionSlider;
@property (weak, nonatomic) IBOutlet UILabel *completionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *deadlineTextField;
@property (weak, nonatomic) IBOutlet UIButton *clearDeadlineButton;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteRecordButton;

- (IBAction)cancelEdit:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (IBAction)textFieldDidChange:(id)sender;
- (IBAction)completionSliderChanged:(id)sender;
- (IBAction)prioritySegmentedControllerChanged:(id)sender;
- (IBAction)clearDeadline:(id)sender;
- (IBAction)deleteTask:(id)sender;

@end
